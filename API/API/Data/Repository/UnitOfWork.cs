using API.Data.IRepository;
using API.Data.IRepository.OrderRepositories;
using API.Data.IRepository.ProductRepositories;
using API.Data.IRepository.UserRepositories;
using API.Data.Repository.OrderRepositories;
using API.Data.Repository.ProductRepositories;
using API.Data.Repository.UserRepositories;

using Microsoft.Extensions.Options;
using MSPS.Data.Repository;

namespace API.Data.Repository
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly ApplicationDbContext _context;
        private readonly IOptions<AppSettings> _appsettings;

        public UnitOfWork(ApplicationDbContext context, IOptions<AppSettings> appSettings)
        {
            _context = context;
            _appsettings = appSettings;


            UserRole = new UserRoleRepository(_context);
            User = new UserRepository(_context, _appsettings);
            RoleAccess = new RoleAccessRepository(_context);

        
            MenuAccess = new MenuAccessRepository(_context);
            Menu = new MenuRepository(_context);

            Route = new RouteRepository(_context);
            RouteAccess = new RouteAccessRepository(_context);

        
            Product = new ProductRepository(_context);
            Brand = new BrandRepository(_context);
            Category = new CategoryRepository(_context);
            Size = new SizeRepository(_context);
            Color = new ColorRepository(_context);
            Stock = new StockRepository(_context);

            Cart = new CartRepository(_context);
            Order = new OrderRepository(_context);
            OrderItem = new OrderItemRepository(_context);

        }

        public IUserRoleRepository UserRole { private set; get; }

        public IRoleAccessRepository RoleAccess { private set; get; }

        public IUserRepository User { private set; get; }

        public IMenuRepository Menu { private set; get; }

        public IMenuAccessRepository MenuAccess { private set; get; }

        public IRouteRepository Route { private set; get; }
        public IRouteAccessRepository RouteAccess { private set; get; }


    
        public IBrandRepository Brand { private set; get; }

        public IProductRepository Product { private set; get; }

        public ICategoryRepository Category { private set; get; }

        public ICartRepository Cart { private set; get; }

        public ISizeRepository Size { private set; get; }

        public IColorRepository Color { private set; get; }

        public IStockRepository Stock { private set; get; }

        public IOrderRepository Order { private set; get; }

        public IOrderItemRepository OrderItem { private set; get; }
        //public IPaymentRepository Payment { private set; get; }
    }
}
