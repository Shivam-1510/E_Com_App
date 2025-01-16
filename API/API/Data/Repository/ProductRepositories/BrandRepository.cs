using API.Data.IRepository.ProductRepositories;
using API.Models.ProductModels;

namespace API.Data.Repository.ProductRepositories
{
    public class BrandRepository : Repository<Brand> , IBrandRepository
    {
        private readonly ApplicationDbContext _context;

        public BrandRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
    }
}
