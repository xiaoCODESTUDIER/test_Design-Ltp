using Microsoft.AspNetCore.Mvc;
using WebApplication1;

namespace testDesign.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ImagePostController : ControllerBase
    {
        private readonly IWebHostEnvironment hostingEnvironment;
        private readonly AppDbContext Database;
        public ImagePostController(IWebHostEnvironment _hostingEnvironment, AppDbContext context)
        {
            hostingEnvironment = _hostingEnvironment;
            Database = context;
        }

        [HttpPost("UploadImage")]
        public async Task<IActionResult> UploadImage(IFormFile? file, string userId)
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
                var uploadsFolder = Path.Combine(hostingEnvironment.WebRootPath, "uploads", "images");
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
                // 返回文件的访问路径
                var imageUrl = $"/uploads/images/{fileName}";
                return Ok(new { imageUrl });
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, $"上传失败：{ex.Message}");
            }
        }
    }
}
