namespace testDesign.Models
{
    public class emailVerificationCodeCheck
    {
        public int Id { get; set; }
        public string email { get; set; } = string.Empty;
        public string code { get; set; } = string.Empty;
    }
}
