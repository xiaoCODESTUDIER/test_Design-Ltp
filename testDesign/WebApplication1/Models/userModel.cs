
namespace WebApplication1.Models
{
    public class userModel
    {
        public int Id { get; set; }
        public string? name { get; set; }
        public int level { get; set; }
        public int isLock { get; set; }
        public string? phoneNum { get; set; }
        public string password { get; set; }
        public string? email { get; set; }
        public string? useName { get; set; }

        public string? avatarUrl { get; set; }
    }
}
