using API.Data.IRepository.ProductRepositories;
using API.Models.ProductModels;

namespace API.Data.Repository.ProductRepositories
{
    public class ColorRepository : Repository<Color>, IColorRepository
    {
        private readonly ApplicationDbContext _context;

        public ColorRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
    }
}
