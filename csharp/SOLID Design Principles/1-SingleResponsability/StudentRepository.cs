using System.Text;

namespace SingleResponsability
{
    public class StudentRepository
    {
        #region Constructors

        public StudentRepository()
        {
            _storage = new();
            InitData();
        }

        #endregion

        #region Public Methods

        public IEnumerable<Student> GetAll() 
        {
            return _storage.GetAll();
        }

        #endregion

        #region Private Methods

        private void InitData()
        {
            _storage.Add(new Student(1, "Pepito Pérez", new List<double>() { 3, 4.5 }));
            _storage.Add(new Student(2, "Mariana Lopera", new List<double>() { 4, 5 }));
            _storage.Add(new Student(3, "José Molina", new List<double>() { 2, 3 }));
        }

        #endregion

        #region Private Members

        private static FakeStorage<Student> _storage;

        #endregion
    }
}