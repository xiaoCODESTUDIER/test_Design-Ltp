using testDesign.Models;

namespace testDesign.Services
{
    public interface INotificationService
    {
        Task<bool> NotifyPostAuthor(int postId, string userId, string comment);
        Task<int> GetUnreadNotificationCount(string userId);
        Task<List<NotificationModel>> GetNotifications(string userId);
        Task MarkNotificationAsRead(int notificationId);
    }
}
