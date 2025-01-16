
using API.Models.Routes;
using API.Data.IRepository.UserRepositories;

namespace API.Data.Repository.UserRepositories
{
    public class RouteAccessRepository:Repository<RouteAccess>,IRouteAccessRepository
    {
        private readonly ApplicationDbContext _context;

        public RouteAccessRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;

        }
    }
}
