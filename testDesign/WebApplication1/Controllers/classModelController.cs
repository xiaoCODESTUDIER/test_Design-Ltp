using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using testDesign.Method;
using testDesign.Models;
using WebApplication1;

namespace testDesign.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class classModelController : ControllerBase
    {
        private readonly AppDbContext Database;
        public classModelController(AppDbContext context)
        {
            Database = context;
        }
        [HttpGet]
        public ActionResult<IEnumerable<classModel>> GetClassModel()
        {
            var classModelList = Database.classModels.ToList();
            foreach (var item in classModelList)
            {
                item.avatarUrl = Database.userModel.First(f => f.name == item.useid).avatarUrl;
            }
            return classModelList;
        }

        [HttpPost("QueryMenuPage")]
        public ActionResult<IEnumerable<classModel>> QueryClassModel(string thamed)
        {
            var classModelList = Database.classModels.Where(w => w.thamed == thamed).ToList();
            foreach (var item in classModelList)
            {
                item.avatarUrl = Database.userModel.First(f => f.name == item.useid).avatarUrl;
            }
            return classModelList;
        }

        [HttpPost]
        public async Task<ActionResult<classModel>> PostClassModel(classModel classModel)
        {
            classModel.eyes = 0;
            classModel.contentsnum = 0;
            classModel.contentid = RandomIdGenerator.GenerateRandomId();
            classModel.goodsid = RandomIdGenerator.GenerateRandomId();
            classModel.userName = Database.userModel.First(f => f.name == classModel.useid).useName!;
            Database.classModels.Add(classModel);
            await Database.SaveChangesAsync();
            return CreatedAtAction(nameof(GetClassModel), new { id = classModel.id }, classModel);
        }

        [HttpPost("AddEyesCount")]
        public async Task AddEyeCount(int id)
        {
            var data = Database.classModels.Where(w => w.id == id).FirstOrDefaultAsync();
            if (data.Result != null)
            {
                data.Result.eyes++;
                data.Result.goodsnum = Database.goodModels.Where(w => w.goodsid == data.Result.goodsid && w.goods == true).Count();
                data.Result.badsnum = Database.goodModels.Where(w => w.goodsid == data.Result.goodsid && w.bads == true).Count();
                data.Result.contentsnum = Database.contentModels.Where(w => w.contentid == data.Result.contentid).Count();
            }
            await Database.SaveChangesAsync();
        }

        [HttpDelete("deleteClass")]
        public async Task<IActionResult> DeleteClassModel(int id)
        {
            var pin = Database.classModels.FirstOrDefault(f => f.id == id);
            if (pin == null)
            {
                return NotFound();
            }
            Database.classModels.Remove(pin);
            await Database.SaveChangesAsync();
            return NoContent();
        }

        [HttpGet("{postId}")]
        public IActionResult GetPost(int postId)
        {
            var post = Database.classModels.FirstOrDefault(p => p.id == postId);
            if (post != null)
            {
                post.contents = Database.contentModels.Where(p => p.contentid == post.contentid).ToList();
                post.goods = Database.goodModels.Where(p => p.goodsid == post.goodsid).ToList();
            }
            if (post != null)
            {
                return Ok(post);
            }
            else
            {
                return NotFound("帖子未找到");
            }
        }
    }
}
