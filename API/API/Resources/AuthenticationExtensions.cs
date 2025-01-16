using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
namespace API.Resources
{
    public static class AuthenticationExtensions
    {
        public static void ConfigureJwtAuthentication(this IServiceCollection services, byte[] key)
        {
            services.AddAuthentication(x =>
            {
                x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            }).AddJwtBearer(x =>
            {
                x.RequireHttpsMetadata = false;
                x.SaveToken = true;
                x.TokenValidationParameters = new TokenValidationParameters()
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = false,
                    ValidateAudience = false
                };
            });
        }

        public static void ConfigureCustomAuthorization(this IServiceCollection services)
        {
            services.AddAuthorization(options =>
            {
                options.AddPolicy(SD.SupremeLevel, x =>
                {
                    x.RequireAuthenticatedUser();
                    x.AddRequirements(new SupremeLevelRequirement());
                });

                options.AddPolicy(SD.IsAccess, x =>
                {
                    x.RequireAuthenticatedUser();
                    x.AddRequirements(new IsAccssRequirement());
                });
            });
        }

    }
}
