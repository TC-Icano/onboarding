using InterfaceSegregation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace _4_InterfaceSegregation
{
    public interface ITesterActivities : IActivities
    {
        //Here we can add more tester specific activities in future if required
    }
}
