using _4_InterfaceSegregation;

namespace InterfaceSegregation
{
    public class Tester : ITesterActivities
    {
        public Tester()
        {
        }

        public void Develop() 
        {
            Console.WriteLine("I'm a Tester and I'm developing the functionalities required");
        }
    }
}