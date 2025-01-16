
using API.Data.IRepository.UserRepositories;
using API.Models.UserModels;

namespace API.Data.Repository.UserRepositories
{
    public class UserRoleRepository : Repository<UserRole>, IUserRoleRepository
    {
        private readonly ApplicationDbContext _context;
        public UserRoleRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
    }
}