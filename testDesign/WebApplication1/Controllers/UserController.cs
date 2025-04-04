using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using testDesign.Models;
using WebApplication1;
using WebApplication1.Models;

namespace testDesign.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly AppDbContext Database;
        public UserController(AppDbContext context)
        {
            Database = context;
        }

        /// <summary>
        /// 用户查看信息操作
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        [HttpPost("UserQuery")]
        public async Task<userModel> QueryUserAsync(string username)
        {
            return await Database.userModel.FirstAsync(f => f.name == username);
        }

        /// <summary>
        /// 用户查看创作帖子操作
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        [HttpPost("ClassQuery")]
        public async Task<List<classModel>> QueryClassAsync(string username)
        {
            return await Database.classModels.Where(f => f.useid == username).ToListAsync();
        }
    }
}
