using API;
using API.Data;
using API.Data.IRepository;
using API.Data.Repository;
using API.Resources;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Swashbuckle.AspNetCore.SwaggerGen;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddHttpContextAccessor();
builder.Services.AddHttpClient();

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<IImageRepository, ImageRepository>();

builder.Services.AddTransient<IConfigureOptions<SwaggerGenOptions>,
    ConfigureSwaggerOptions>();


builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var appSettings = builder.Configuration.GetSection("AppSettings");
builder.Services.Configure<AppSettings>(appSettings);
var appSetting = appSettings.Get<AppSettings>();
var key = Encoding.ASCII.GetBytes(appSetting.Secret);

builder.Services.ConfigureJwtAuthentication(key);
builder.Services.ConfigureCustomAuthorization();

builder.Services.AddScoped<IAuthorizationHandler, IsAccssAuthorizationHandler>();

builder.Services.AddScoped<IAuthorizationHandler, SupremeLevelAuthorizationHandler>();

//cors to run api on different ports
builder.Services.AddCors(options =>
{
    options.AddPolicy(name: "MyPolicy",
    builder =>
    {
        builder
            .WithOrigins("http://localhost:5173") // Add Flutter app origin here
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials(); // Allows cookies if needed
    });
});


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("MyPolicy");

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();