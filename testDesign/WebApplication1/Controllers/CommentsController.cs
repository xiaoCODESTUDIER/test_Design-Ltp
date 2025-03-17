using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using testDesign.Method;
using testDesign.Models;
using testDesign.Services;
using WebApplication1;

namespace testDesign.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CommentsController : ControllerBase
    {
        private readonly AppDbContext Database;
        private readonly INotificationService Notify;
        public CommentsController(AppDbContext context, INotificationService notify)
        {
            Database = context;
            Notify = notify;
        }

        [HttpPost("add")]
        public async Task<ActionResult> AddComment([FromBody] contentModel content)
        {
            if (content == null)
            {
                return BadRequest("Invalid comment data");
            }
            try
            {
                // 添加评论到数据库
                content.goodsid = RandomIdGenerator.GenerateRandomId();
                Database.contentModels.Add(content);
                await Database.SaveChangesAsync();

                // 通知帖子作者
               // await Notify.NotifyPostAuthor(Convert.ToInt32(content.contentid), content.Useid, content.Commnet);
                return CreatedAtAction(nameof(GetComment), new { id = content.id }, content);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"服务器错误：{ex.Message}");
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<List<contentModel>>> GetComment(string id)
        {
            var comment = await Database.contentModels.Where(w => w.contentid == id).ToListAsync();
            if (comment == null)
            {
                return NotFound();
            }
            return comment;
        }

        [HttpPost("like")]
        public async Task<IActionResult> LikeAsync(string contentId, string goodsId, string useId)
        {
            var classData = Database.classModels.Where(w => w.contentid == contentId).FirstOrDefault();
            if (classData == null)
            {
                return NotFound("没有找到相关评论！");
            }

            var goodsData = Database.goodModels.Where(w => w.goodsid == goodsId && w.useid == useId)?.FirstOrDefault();
            if (goodsData == null)
            {
                var goodData = new goodModel();
                goodData.goodsid = goodsId;
                goodData.useid = useId;
                goodData.goods = true;
                goodData.bads = false;
                goodData.goodsDate = DateTime.Now;
                Database.goodModels.Add(goodData);
                classData.goodsnum++;
            }
            else
            {
                goodsData.goods = true;
                classData.goodsnum++;
                goodsData.goodsDate = DateTime.Now;
            }
            await Database.SaveChangesAsync();
            return Ok(classData);
        }

        [HttpPost("cancelLike")]
        public async Task<IActionResult> CancelLikeAsync(string contentId, string goodsId, string useId)
        {
            var classData = Database.classModels.Where(w => w.contentid == contentId).FirstOrDefault();
            if (classData == null)
            {
                return NotFound("没有找到相关评论！");
            }

            var goodsData = Database.goodModels.Where(w => w.goodsid == goodsId && w.useid == useId)?.FirstOrDefault();
            if (goodsData == null)
            {
                return NotFound("没有找到相关评论！");
            }
            else
            {
                goodsData.goods = false;
                classData.goodsnum--;
                goodsData.goodsDate = DateTime.Now;
            }
            await Database.SaveChangesAsync();
            return Ok(classData);
        }

        [HttpPost("dislike")]
        public async Task<IActionResult> DislikeAsync(string contentId, string goodsId, string useId)
        {
            var classData = Database.classModels.Where(w => w.contentid == contentId).FirstOrDefault();
            if (classData == null)
            {
                return NotFound("没有找到相关评论！");
            }

            var goodsData = Database.goodModels.Where(w => w.goodsid == goodsId && w.useid == useId)?.FirstOrDefault();
            if (goodsData == null)
            {
                var goodData = new goodModel();
                goodData.goodsid = goodsId;
                goodData.useid = useId;
                goodData.goods = false;
                goodData.bads = true;
                goodData.goodsDate = DateTime.Now;
                classData.badsnum++;
            }
            else
            {
                goodsData.bads = true;
                classData.badsnum++;
                goodsData.goodsDate = DateTime.Now;
            }
            await Database.SaveChangesAsync();
            return Ok(classData);
        }

        [HttpPost("cancelDislike")]
        public async Task<IActionResult> CancelDislikeAsync(string contentId, string goodsId, string useId)
        {
            var classData = Database.classModels.Where(w => w.contentid == contentId).FirstOrDefault();
            if (classData == null)
            {
                return NotFound("没有找到相关评论！");
            }

            var goodsData = Database.goodModels.Where(w => w.goodsid == goodsId && w.useid == useId)?.FirstOrDefault();
            if (goodsData == null)
            {
                return NotFound("没有找到相关评论！");
            }
            else
            {
                goodsData.bads = false;
                classData.badsnum--;
                goodsData.goodsDate = DateTime.Now;
            }
            await Database.SaveChangesAsync();
            return Ok(classData);
        }

        [HttpGet("getGoodsByContentId")]
        public IActionResult GetGoodsByContentId(string goodsId)
        {
            var goodData = Database.goodModels.Where(w => w.goodsid == goodsId).ToList();
            if (goodData == null)
            {
                return NotFound("没有找到相关评论！");
            }
            return Ok(goodData);
        }
    }
}
