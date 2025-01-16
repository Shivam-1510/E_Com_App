using API.Models.Menus;
using API.Data.IRepository.UserRepositories;

namespace API.Data.Repository.UserRepositories
{
    public class MenuAccessRepository : Repository<MenuAccess>, IMenuAccessRepository
    {
        private readonly ApplicationDbContext _context;
        public MenuAccessRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;

        }
    }
}
