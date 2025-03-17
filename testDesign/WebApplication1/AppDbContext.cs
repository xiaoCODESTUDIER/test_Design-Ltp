using Microsoft.EntityFrameworkCore;
using testDesign.Models;
using WebApplication1.Models;

namespace WebApplication1
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions options) : base(options)
        {
        }

        public DbSet<userModel> userModel { get; set; }
        public DbSet<emailVerificationCodeCheck> emailVerificationCodeChecks { get; set; }
        public DbSet<classModel> classModels { get; set; }
        public DbSet<contentModel> contentModels { get; set; }
        public DbSet<goodModel> goodModels { get; set; }
        public DbSet<NotificationModel> notificationModels { get; set; }
        public DbSet<NotificationRequestModel> notificationRequestModels { get; set; }
    }
}
