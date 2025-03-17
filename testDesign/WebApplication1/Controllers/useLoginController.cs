using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Xrm.Sdk.Workflow.Activities;
using Org.BouncyCastle.Asn1.Pkcs;
using System.Linq.Expressions;
using System.Net;
using System.Net.Mail;
using testDesign.Models;
using WebApplication1;
using WebApplication1.Models;

namespace testDesign.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class useLoginController : ControllerBase
    {
        private readonly AppDbContext Database;
        private readonly Dictionary<string, string> _verificationCodes = new Dictionary<string, string>();
        public useLoginController(AppDbContext context)
        {
            Database = context;
        }
        [HttpGet]
        public async Task<ActionResult<IEnumerable<userModel>>> GetUsers()
        {
            return await Database.userModel.ToListAsync();
        }
        [HttpPost("login")]
        public async Task<IActionResult> LoginRquest([FromBody] LoginRequest request)
        {
            var data = await Database.userModel.FirstOrDefaultAsync(u => u.name == request.username && u.password == request.password);
            if (data != null)
            {
                return Ok(new { message = data.name});
            }
            else
            {
                return Unauthorized(new { message = "账户或密码不正确，请重新输入" });
            }
        }
        // 发送验证码方法
        [HttpPost("sendVerificationCode")]
        public async Task<IActionResult> SendVerificationCode([FromBody] EmailRequest email)
        {
            // 先检查是否又被注册的邮箱
            var emailList = Database.userModel.ToList();
            if (emailList.Any(a => a.email == email.Email))
            {
                return BadRequest("该邮箱已被注册！");
            }
            if (!IsValidEmail(email.Email))
            {
                return BadRequest("无效的邮箱地址");
            }
            //SendEmail e = new SendEmail();
            string code = SendEmail(email.Email, "嘿！");
            // 将生成的 验证码和对应的email 存起来，方便后续进行验证码验证
            var emailVerificationCodeCheck = new emailVerificationCodeCheck();
            var checkList = await Database.emailVerificationCodeChecks.ToListAsync();
            if (checkList.Any(a => a.email == email.Email))
            {
                checkList.First(w => w.email == email.Email).code = code;
            }
            else
            {
                emailVerificationCodeCheck.code = code;
                emailVerificationCodeCheck.email = email.Email;
                Database.emailVerificationCodeChecks.Add(emailVerificationCodeCheck);
            }
            await Database.SaveChangesAsync();
            if (code.Length == 6 && int.TryParse(code, out _))
            {
                return Ok(new { Message = "验证码已发送", VerificationCode = code });
            }
            else
            {
                return BadRequest(new { Message = code });
            }
        }
        // 验证验证码方法
        [HttpPost("verifyVerificationCode")]
        public IActionResult VerifyVerificationCode([FromBody] VerificationRequest request)
        {
            if (string.IsNullOrEmpty(request.Email) || string.IsNullOrEmpty(request.VerificationCode))
            {
                return BadRequest("邮箱地址和验证码不能为空");
            }

            // 验证验证码是否正确
            bool isVerified = VerifyCode(request.Email, request.VerificationCode);

            if (isVerified)
            {
                return Ok(new { Message = "验证码正确" });
            }
            else
            {
                return BadRequest(new { Message = "验证码错误" });
            }
        }

        private bool VerifyCode(string email, string verificationCode)
        {
            // 实现验证码验证逻辑
            var checkCodeList = Database.emailVerificationCodeChecks.ToList();
            return checkCodeList.Any(w => w.email == email && w.code == verificationCode);
        }
        [HttpPost]
        public async Task<string> Register(userModel user)
        {
            try
            {
                var dataList = Database.userModel.ToList();
                if (dataList.Any(w => w.name == user.name))
                {
                    return "该用户名已被注册！";
                }
                user.isLock = 0;
                user.level = 1;
                Database.userModel.Add(user);
                await Database.SaveChangesAsync();
                return "注册成功！";
            }
            catch (Exception ex)
            {
                Console.WriteLine($"注册失败：｛ex.Message｝");
                return $"注册失败，请稍后再试！{ex}";
            }
        }
        // 创建随机六位数验证码
        private string GenerateVerificationCode()
        {
            Random random = new Random();
            return random.Next(100000, 999999).ToString();
        }
        // 检查邮箱格式是否正确
        private bool IsValidEmail(string email)
        {
            try
            {
                MailAddress m = new MailAddress(email);
                return true;
            }
            catch (FormatException)
            {
                return false;
            }
        }
        private string SendEmail(string toAddress, string subject)
        {
            // 设置发件人邮箱地址以及授权码
            string fromAddress = "1141106813@qq.com";
            string password = "gnwpbnqaachojiac";
            string randomCode = GenerateVerificationCode();
            //创建邮件消息对象
            MailMessage mail = new MailMessage();
            mail.From = new MailAddress(fromAddress);
            // 要发送去的邮箱
            mail.To.Add(new MailAddress(toAddress));
            // 邮箱的名字
            mail.Subject = subject;
            // 邮箱的正文
            mail.Body = @"<html>
                            <head>
                                <style>
                                    h1 {
                                            color: #333;
                                            font-family: Arial, sans-serif;
                                    }
                                    p {
                                            color: #555;
                                            font-family: Arial, sans-serif;
                                    }
                                    strong {
                                            color: #f00;
                                            font-weight: bold;
                                    }
                                </style>
                             </head>
                             <body>
                                <h1>验证码</h1>
                                <p>您的验证码为：<strong>" + randomCode + @"</strong></p>
                             </body>
                          </html>";
            using (var client = new SmtpClient("smtp.qq.com", 587))
            {
                client.EnableSsl = true;
                client.Credentials = new NetworkCredential(fromAddress, password);
                // 发送邮件
                client.Send(mail);
                Console.WriteLine("邮件发送成功!");
            }

            try
            {
                return randomCode;
            }
            catch (Exception ex)
            {
                return $"验证码发送失败，请稍后再试！ {ex}";
            }
        }
    }

    public class EmailRequest
    {
        public string Email { get; set; } = string.Empty;
    }
    public class VerificationRequest
    {
        public string Email { get; set; } = string.Empty;
        public string VerificationCode { get; set; } = string.Empty;
    }
    public class LoginRequest
    {
        public string username { get; set; } = string.Empty;
        public string password { get; set; } = string.Empty;
    }
}
