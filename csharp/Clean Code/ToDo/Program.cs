using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ToDo
{
    internal class Program
    {
        #region Main

        static void Main(string[] args)
        {
            Tasks = new List<string>();
            
            AplicationStartup();
        }

        #endregion

        #region Private Methods

        /// <summary>
        /// Starts ToDo menu
        /// </summary>
        private static void AplicationStartup()
        {
            int selectedOption;

            do
            {
                selectedOption = DisplayMenuOptions();

                switch (selectedOption)
                {
                    case 1:
                        DisplayNewTaskOption();
                        break;
                    case 2:
                        DisplayRemoveTaskOption();
                        break;
                    case 3:
                        DisplayPendingTasksOption();
                        break;
                    default:
                        // If selectedOption is 4 then exit from system otherwise non valid option
                        string message = selectedOption == 4 ? "Exit option selected..." : "Must enter a valid option";

                        Console.WriteLine(message);
                        break;
                }

            } while (selectedOption != 4);
        }

        /// <summary>
        /// Display available options for ToDo system
        /// </summary>
        /// <returns>
        /// - return typed if it is number otherwise return 0
        /// </returns>
        private static int DisplayMenuOptions()
        {
            Console.WriteLine(SectionLine);
            Console.WriteLine("Enter the option to perform: ");
            Console.WriteLine("1. New task");
            Console.WriteLine("2. Remove task");
            Console.WriteLine("3. Pending tasks");
            Console.WriteLine("4. Exit");

            // Get typed value and try convert it to int
            bool isValidOption = Int32.TryParse(Console.ReadLine(), out int selectedOption);

            // If is valid option return selectedOption, otherwise return 0
            return isValidOption ? selectedOption : 0;
        }

        /// <summary>
        /// Add new item into Task
        /// </summary>
        private static void DisplayNewTaskOption()
        {
            try
            {
                Console.WriteLine("Enter the name of the task: ");

                string? taskName = Console.ReadLine();
                if (string.IsNullOrEmpty(taskName))
                {
                    Console.WriteLine("Must enter a task name");
                    return;
                }

                Tasks.Add(taskName);

                Console.WriteLine("Task registered successfully");
            }
            catch (Exception)
            {
                Console.WriteLine("An unexpected error occurred while registering new task. Try again or contact support");
            }
        }

        /// <summary>
        /// Delete item from Task
        /// </summary>
        private static void DisplayRemoveTaskOption()
        {
            try
            {
                if (Tasks?.Count <= 0)
                {
                    Console.WriteLine("There are not tasks to be removed");
                    return;
                }

                Console.WriteLine("Enter the number of the task to remove: ");

                // Display existing taks
                for (int index = 0; index < Tasks.Count; index ++)
                {
                    Console.WriteLine($"{index + 1}. {Tasks[index]}");
                }

                Console.WriteLine(SectionLine);

                // Validate if typed value is int
                bool isValidOption = Int32.TryParse(Console.ReadLine(), out int taskNumber);
                if (!isValidOption)
                {
                    Console.WriteLine("Must enter a valid number");
                    return;
                }

                // Validate if typed number is not into Tasks options
                if(taskNumber < 1 || taskNumber > Tasks.Count)
                {
                    Console.WriteLine($"Task number ({taskNumber}) does not exist");
                    return;
                }

                // Set task index to be removed
                int indexToRemove = taskNumber - 1;

                Tasks.RemoveAt(indexToRemove);

                Console.WriteLine($"Task {Tasks[indexToRemove]} deleted");
            }
            catch (Exception)
            {
                Console.WriteLine("An unexpected error occurred wihle removing task. Try again or contact support");
            }
        }

        /// <summary>
        /// Show available items from Task
        /// </summary>
        private static void DisplayPendingTasksOption()
        {
            try
            {
                // Check if exists any tasks
                if (!Tasks.Any())
                {
                    Console.WriteLine("There are no tasks to perform");
                    return;
                }

                Console.WriteLine(SectionLine);

                // Display existing tasks
                for (int index = 0; index < Tasks?.Count; index++)
                {
                    Console.WriteLine($"{index + 1}. {Tasks[index]}");
                }

                Console.WriteLine(SectionLine);
            }
            catch (Exception)
            {
                Console.WriteLine("An unexpected error occurred. Try again or contact support");
            }
        }

        #endregion

        #region Public Properties

        public static List<string> Tasks { get; set; }

        #endregion

        #region Private Members

        private const string SectionLine = "----------------------------------------";

        #endregion

    }
}
