
using API.Data.IRepository.UserRepositories;
using API.Models.UserModels;

namespace API.Data.Repository.UserRepositories
{
    public class RoleAccessRepository : Repository<RoleAccess>, IRoleAccessRepository
    {
        private readonly ApplicationDbContext _context;

        public RoleAccessRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;

        }
    }
}
