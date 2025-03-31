using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using testDesign.Models;
using WebApplication1;
using WebApplication1.Models;

namespace testDesign.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdminController : ControllerBase
    {
        private readonly AppDbContext Database;
        public AdminController(AppDbContext context)
        {
            Database = context;
        }

        [HttpGet("QueryUser")]
        public async Task<List<userModel>> QueryUsersAsync()
        {
            return await Database.userModel.ToListAsync();
        }

        [HttpGet("QueryClass")]
        public async Task<List<classModel>> QueryClassesAsync()
        {
            return await Database.classModels.ToListAsync();
        }

        /// <summary>
        /// 用户冻结操作
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        [HttpPost("UserLock")]
        public async Task LockUserAsync(string name)
        {
            var data = await Database.userModel.FirstAsync(w => w.name == name);
            data.isLock = 1;
            Database.UpdateRange(data);
            await Database.SaveChangesAsync();
        }

        /// <summary>
        /// 用户解除冻结操作
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        [HttpPost("UserEffect")]
        public async Task EffectUserAsync(string name)
        {
            var data = await Database.userModel.FirstAsync(w => w.name == name);
            data.isLock = 0;
            Database.UpdateRange(data);
            await Database.SaveChangesAsync();
        }
    }
}
