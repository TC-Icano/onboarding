using _4_InterfaceSegregation;

namespace InterfaceSegregation
{
    public class Developer : IDeveloperActivities
    {
        public Developer()
        {
        }

        public void Develop() 
        {
            Console.WriteLine("I'm a Developer and I'm developing the functionalities required");
        }
    }
}