using System.Text;

namespace testDesign.Method
{
    public static class RandomIdGenerator
    {
        private static readonly Random random = new Random();

        public static string GenerateRandomId(int length = 13)
        {
            const string digits = "0123456789abcd";
            StringBuilder sb = new StringBuilder(length);
            for (int i = 0; i < length; i++)
            {
                sb.Append(digits[random.Next(digits.Length)]);
            }
            return sb.ToString();
        }
    }
}
