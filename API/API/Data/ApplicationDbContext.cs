using API.Models.Menus;
using API.Models.OrderModels;
using API.Models.PaymentModels;
using API.Models.ProductModels;
using API.Models.Routes;
using API.Models.UserModels;
using Microsoft.EntityFrameworkCore;
using Route = API.Models.Routes.Route;

namespace API.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
        {
        }

        public DbSet<UserRole> UserRole { get; set; }
        public DbSet<User> User { get; set; }
        public DbSet<RoleAccess> RoleAccess { get; set; }



        public DbSet<Menu> Menu { get; set; }
        public DbSet<MenuAccess> MenuAccess { get; set; }

        public DbSet<Route> Route { get; set; }
        public DbSet<RouteAccess> RouteAccess { get; set; }


        public DbSet<Brand> Brand { get; set; }
        public DbSet<Product> Product { get; set; }
        public DbSet<Category> Category { get; set; }
        public DbSet<Size> Size { get; set; }
        public DbSet<Color> Color { get; set; }
        public DbSet<Stock> Stock { get; set; }


        public DbSet<Cart> Cart { get; set; }
        public DbSet<Order> Order { get; set; }
        public DbSet<OrderItem> OrderItem { get; set; }

        //public DbSet<PaymentVM> Payment { get; set; }

        //modelBuilder.Entity<PaymentVM>()
        //    .HasOne(c => c.Order)
        //    .WithMany()
        //    .HasForeignKey(c => c.OrderCode);



        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<RoleAccess>()
             .HasOne(ura => ura.User)
             .WithMany()
             .HasForeignKey(ura => ura.UserCode);

            modelBuilder.Entity<RoleAccess>()
            .HasOne(ura => ura.UserRole)
            .WithMany()
            .HasForeignKey(ura => ura.RoleCode);

            modelBuilder.Entity<MenuAccess>()
           .HasOne(c => c.UserRole)
           .WithMany()
           .HasForeignKey(c => c.RoleCode);

            modelBuilder.Entity<MenuAccess>()
            .HasOne(c => c.Menu)
            .WithMany()
            .HasForeignKey(c => c.MenuCode);

            modelBuilder.Entity<RouteAccess>()
            .HasOne(c => c.UserRole)
            .WithMany()
            .HasForeignKey(c => c.RoleCode);

            modelBuilder.Entity<RouteAccess>()
            .HasOne(c => c.Route)
            .WithMany()
            .HasForeignKey(c => c.RouteCode);



            modelBuilder.Entity<Product>()
            .HasOne(cu => cu.User)
            .WithMany()
            .HasForeignKey(cu => cu.UserCode);
            
            modelBuilder.Entity<Product>()
            .HasOne(cu => cu.Brand)
            .WithMany()
            .HasForeignKey(cu => cu.BrandCode);

            modelBuilder.Entity<Product>()
            .HasOne(cu => cu.Category)
            .WithMany()
            .HasForeignKey(cu => cu.CategoryCode);


            modelBuilder.Entity<Stock>()
            .HasOne(cu => cu.Size)
            .WithMany()
            .HasForeignKey(cu => cu.SizeCode);

            modelBuilder.Entity<Stock>()
            .HasOne(cu => cu.Color)
            .WithMany()
            .HasForeignKey(cu => cu.ColorCode);

            modelBuilder.Entity<Stock>()
            .HasOne(cu => cu.Product)
            .WithMany()
            .HasForeignKey(cu => cu.ProductCode);


            modelBuilder.Entity<Cart>()
            .HasOne(c => c.User)
            .WithMany()
            .HasForeignKey(c => c.UserCode);

            modelBuilder.Entity<Cart>()
            .HasOne(c => c.Color)
            .WithMany()
            .HasForeignKey(c => c.ColorCode);

            modelBuilder.Entity<Cart>()
            .HasOne(c => c.Size)
            .WithMany()
            .HasForeignKey(c => c.SizeCode);

            modelBuilder.Entity<Cart>()
            .HasOne(c => c.Product)
            .WithMany()
            .HasForeignKey(c => c.ProductCode);



            modelBuilder.Entity<Order>()
            .HasOne(c => c.User)
            .WithMany()
            .HasForeignKey(c => c.UserCode);

            modelBuilder.Entity<OrderItem>()
            .HasOne(c => c.Color)
            .WithMany()
            .HasForeignKey(c => c.ColorCode);

            modelBuilder.Entity<OrderItem>()
            .HasOne(c => c.Order) 
            .WithMany()
            .HasForeignKey(c => c.OrderCode);

            modelBuilder.Entity<OrderItem>()
            .HasOne(c => c.Size)
            .WithMany()
            .HasForeignKey(c => c.SizeCode);

            modelBuilder.Entity<OrderItem>()
            .HasOne(c => c.Product)
            .WithMany()
            .HasForeignKey(c => c.ProductCode);
            
            
         



        }
    }
}
