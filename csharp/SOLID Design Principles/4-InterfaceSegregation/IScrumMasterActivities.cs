using InterfaceSegregation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace _4_InterfaceSegregation
{
    public interface IScrumMasterActivities : IActivities
    {
        /// <summary>
        /// Generates a plan based on the current state and configuration.
        /// </summary>
        void Plan();

        /// <summary>
        /// Initiates communication between the system and an external entity.
        /// </summary>
        void Communicate();

        /// <summary>
        /// Initiates the design process for the current object or system.
        /// </summary>
        void Design();

        /// <summary>
        /// Executes a test operation.
        /// </summary>
        void Test();

        //Here we can add more ScrumMaster specific activities in future if required
    }
}
