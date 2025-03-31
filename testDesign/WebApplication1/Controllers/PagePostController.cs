using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.IO;    
using WebApplication1;

namespace testDesign.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PagePostController : ControllerBase
    {
        private readonly IWebHostEnvironment hostingEnvironment;
        private readonly AppDbContext Database;
        public PagePostController(IWebHostEnvironment _hostingEnvironment, AppDbContext context)
        {
            hostingEnvironment = _hostingEnvironment;
            Database = context;
        }

        [HttpPost("UploadAvatar")]
        public async Task<IActionResult> UploadAvatar(IFormFile file, string? userId)
        {
            try
            {
                if (file == null || file.Length == 0)
                {
                    return BadRequest("未上传文件");
                }
                // 确保上传的是图片
                if (!file.ContentType.StartsWith("image/"))
                {
                    return BadRequest("仅支持图片格式");
                }
                // 定义保存路径
                var uploadsFolder = Path.Combine(hostingEnvironment.WebRootPath, "uploads", "avatars");
                if (!Directory.Exists(uploadsFolder))
                {
                    Directory.CreateDirectory(uploadsFolder);
                }
                // 生成唯一文件名
                var fileName = $"{userId}_{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
                var filePath = Path.Combine(uploadsFolder, fileName);

                // 保存文件
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                // 更新数据库中的 avatarUrl
                var user = await Database.userModel.FindAsync(userId);
                if (user == null)
                {
                    return NotFound("用户不存在");
                }

                // 删除旧头像
                if (!string.IsNullOrEmpty(user.avatarUrl))
                {
                    var oldFilePath = Path.Combine(hostingEnvironment.WebRootPath, user.avatarUrl.TrimStart('/'));
                    if (System.IO.File.Exists(oldFilePath))
                    {
                        System.IO.File.Delete(oldFilePath);
                    }
                }
                // 返回文件的访问路径
                var avatarUrl = $"/uploads/avatars/{fileName}";
                await Database.SaveChangesAsync();
                return Ok(new { avatarUrl = user.avatarUrl });
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, $"上传失败：{ex.Message}");
            }
        }
    }
}
