using API.Data.IRepository.OrderRepositories;
using API.Data.IRepository.ProductRepositories;
using API.Data.IRepository.UserRepositories;

namespace API.Data.IRepository
{
    public interface IUnitOfWork
    {
        IUserRoleRepository UserRole { get; }
        IRoleAccessRepository RoleAccess { get; }
        IUserRepository User { get; }

      
        IMenuRepository Menu { get; }
        IMenuAccessRepository MenuAccess { get; }
        IRouteRepository Route { get; }
        IRouteAccessRepository RouteAccess { get; }


        IBrandRepository Brand { get; }
        IProductRepository Product { get; }
        ICategoryRepository Category { get; }
        ISizeRepository Size { get; }
        IColorRepository Color { get; }
        IStockRepository Stock { get; }


        ICartRepository Cart { get; }
        IOrderRepository Order { get; }
        IOrderItemRepository OrderItem { get; }


        //IPaymentRepository Payment { get; }



    }
}
