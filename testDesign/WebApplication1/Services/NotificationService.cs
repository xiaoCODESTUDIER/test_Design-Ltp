using Microsoft.EntityFrameworkCore;
using testDesign.Models;
using WebApplication1;

namespace testDesign.Services
{
    public class NotificationService : INotificationService
    {
        private readonly AppDbContext Database;
        public NotificationService(AppDbContext context)
        {
            Database = context;
        }

        public async Task<bool> NotifyPostAuthor(int postId, string userId, string comment)
        {
            // 获取帖子的作者ID
            var post = await Database.classModels.FindAsync(postId);
            if (post == null)
            {
                return false;
            }

            // 创建通知对象
            var notification = new NotificationModel
            {
                PostId = postId,
                UserId = post.useid,
                Content = $"用户 {userId} 在你的帖子中评论了：{comment}",
                CreatedAt = DateTime.Now
            };

            // 存储通知到数据库
            Database.notificationModels.Add(notification);
            return await Database.SaveChangesAsync() > 0;
        }
        public async Task<int> GetUnreadNotificationCount(string userId)
        {
            return await Database.notificationModels.CountAsync(n => n.UserId == userId && !n.IsRead);
        }

        // 获取通知列表
        public async Task<List<NotificationModel>> GetNotifications(string userId)
        {
            var data = await Database.notificationModels
                .Where(n => n.UserId == userId && n.IsRead == false)
                .OrderByDescending(n => n.CreatedAt)
                .ToListAsync();
            return data;
        }

        // 标记通知为已读
        public async Task MarkNotificationAsRead(int notificationId)
        {
            var notification = await Database.notificationModels.FindAsync(notificationId);
            if (notification != null)
            {
                notification.IsRead = true;
                await Database.SaveChangesAsync();
            }
        }
    }
}
