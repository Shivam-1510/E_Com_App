using API.Data.IRepository.ProductRepositories;
using API.Models.ProductModels;

namespace API.Data.Repository.ProductRepositories
{
    public class SizeRepository : Repository<Size>, ISizeRepository
    {
        private readonly ApplicationDbContext _context;
        public SizeRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
    }
}
