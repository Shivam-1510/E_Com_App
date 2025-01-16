
using API;
using API.Data;
using API.Data.IRepository.UserRepositories;
using API.Data.Repository;
using API.Models.UserModels;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace MSPS.Data.Repository
{
    public class UserRepository : Repository<User>, IUserRepository
    {
        private readonly ApplicationDbContext _context;
        private readonly AppSettings _appSettings;
        public UserRepository(ApplicationDbContext context, IOptions<AppSettings> appSettings) : base(context)
        {
            _context = context;
            _appSettings = appSettings.Value;

        }

        public async Task<bool> ActiveDeactiveUser(string userCode)
        {
            try
            {
                var userindb = _context.User.FirstOrDefault(x => x.UserCode == userCode);
                if (userindb == null)
                {
                    return false;
                }
                else
                {
                    if (userindb.IsActive == true)
                        userindb.IsActive = false;
                    else
                        userindb.IsActive = true;

                    await _context.SaveChangesAsync();
                    return true;
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.ToString());
            }
        }

        public async Task<string> Authenticate(string MobileNumber, string roleId)
        {
            try
            {
                var userindb = await dbSet.FirstOrDefaultAsync(x => x.MobileNumber == MobileNumber);
                if (userindb == null)
                    return null;
                //jwt
                var tokenHandler = new JwtSecurityTokenHandler();
                var key = Encoding.ASCII.GetBytes(_appSettings.Secret);
                var tokenDescritor = new SecurityTokenDescriptor()
                {
                    Subject = new ClaimsIdentity(new Claim[]
                    {
                    new Claim(ClaimTypes.Role, roleId),
                    new Claim(ClaimTypes.SerialNumber, userindb.UserCode),
                    new Claim(ClaimTypes.MobilePhone, userindb.MobileNumber)
                    }),
                    Expires = DateTime.UtcNow.AddHours(24),
                    SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key),
                    SecurityAlgorithms.HmacSha256Signature)
                };
                var token = tokenHandler.CreateToken(tokenDescritor);
                userindb.Token = tokenHandler.WriteToken(token);
                return userindb.Token;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.ToString());
            }

        }

        public async Task<bool> IsUniqueUser(string MobileNumber)
        {
            try
            {
                var userindb = await dbSet.FirstOrDefaultAsync(x => x.MobileNumber == MobileNumber);
                if (userindb == null)
                    return true;
                return false;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.ToString());
            }
        }

        public async Task<bool> RegisterUser(User User)
        {
            try
            {
                await dbSet.AddAsync(User);
                await _context.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.ToString());
            }
        }
    }
}


