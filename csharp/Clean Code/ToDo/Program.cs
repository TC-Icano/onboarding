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
                    case NewTaskOption:
                        DisplayNewTaskOption();
                        break;
                    case RemoveTaskOption:
                        DisplayRemoveTaskOption();
                        break;
                    case PendingTasksOption:
                        DisplayPendingTasksOption();
                        break;
                    case ExitOption:
                        DisplayFinishAppOption();
                        break;
                    default:
                        Console.WriteLine(Resources.ToDoResources.Menu_Error_InvalidOption);
                        break;
                }

            } while (selectedOption != ExitOption);
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
            Console.WriteLine(Resources.ToDoResources.Menu_Caption_Title);
            Console.WriteLine(Resources.ToDoResources.Menu_Option_NewTask);
            Console.WriteLine(Resources.ToDoResources.Menu_Option_RemoveTask);
            Console.WriteLine(Resources.ToDoResources.Menu_Option_PendingTasks);
            Console.WriteLine(Resources.ToDoResources.Menu_Option_Exit);

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
                Console.WriteLine(Resources.ToDoResources.NewTask_Caption_Title);

                string taskName = Console.ReadLine();
                if (string.IsNullOrEmpty(taskName))
                {
                    Console.WriteLine(Resources.ToDoResources.NewTask_Error_InvalidTaskName);
                    return;
                }

                Tasks.Add(taskName);

                Console.WriteLine(Resources.ToDoResources.NewTask_Caption_Success);
            }
            catch (Exception)
            {
                Console.WriteLine(Resources.ToDoResources.NewTask_Error_Exception);
            }
        }

        /// <summary>
        /// Delete item from Task
        /// </summary>
        private static void DisplayRemoveTaskOption()
        {
            try
            {
                if (!Tasks.Any())
                {
                    Console.WriteLine(Resources.ToDoResources.RemoveTask_Error_NotTasks);
                    return;
                }

                Console.WriteLine(Resources.ToDoResources.RemoveTask_Caption_Title);

                // Display existing taks
                for (int index = 0; index < Tasks.Count; index ++)
                {
                    Console.WriteLine(String.Format(Resources.ToDoResources.RemoveTask_Caption_IndexTask, index + 1, Tasks[index]));
                }

                Console.WriteLine(SectionLine);

                // Validate if typed value is int
                bool isValidOption = Int32.TryParse(Console.ReadLine(), out int taskNumber);
                if (!isValidOption)
                {
                    Console.WriteLine(Resources.ToDoResources.RemoveTask_Error_InvalidNumber);
                    return;
                }

                // Validate if typed number is not into Tasks options
                if(taskNumber < 1 || taskNumber > Tasks.Count)
                {
                    Console.WriteLine(String.Format(Resources.ToDoResources.RemoveTask_Error_TaskNotFound, taskNumber));
                    return;
                }

                // Set task index to be removed
                int indexToRemove = taskNumber - 1;
                string taskName = Tasks[indexToRemove];
                Tasks.RemoveAt(indexToRemove);

                Console.WriteLine(String.Format(Resources.ToDoResources.RemoveTask_Caption_Success, taskName));
            }
            catch (Exception)
            {
                Console.WriteLine(Resources.ToDoResources.RemoveTask_Error_Exception);
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
                    Console.WriteLine(Resources.ToDoResources.PendingTasks_Error_NotTasks);
                    return;
                }

                Console.WriteLine(SectionLine);

                // Display existing tasks
                for (int index = 0; index < Tasks?.Count; index++)
                {
                    Console.WriteLine(String.Format(Resources.ToDoResources.PendingTasks_Caption_IndexTask, index + 1, Tasks[index]));
                }

                Console.WriteLine(SectionLine);
            }
            catch (Exception)
            {
                Console.WriteLine(Resources.ToDoResources.PendingTasks_Error_Exception);
            }
        }

        /// <summary>
        /// Works as exit option functionality
        /// </summary>
        private static void DisplayFinishAppOption()
        {
            Console.WriteLine(Resources.ToDoResources.Menu_Caption_FinishApp);
        }

        #endregion

        #region Public Properties

        public static List<string> Tasks { get; set; }

        #endregion

        #region Private Members

        private const string SectionLine = "----------------------------------------";
        private const int NewTaskOption = 1;
        private const int RemoveTaskOption = 2;
        private const int PendingTasksOption = 3;
        private const int ExitOption = 4;

        #endregion

    }
}
