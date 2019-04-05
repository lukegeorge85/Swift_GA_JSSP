import Cocoa

struct Task {
    var job: Int
    var sequence: Int
    var machine: Int
    var time: Int
    var finishTime: Int
}

struct Population {
    var timeToComplete: Int
    var solution: [Task]
}

/// No. of machines available
let noOfMachines = 5
/// Array to hold the solutions
var solutions = [Population]()

func fitnessFunction(solution: [Task]) -> Int {
    /// Initialise empty arrays to act as the machines
    var machines = Array(repeating: Array(repeating: Task(job: 0, sequence: 0, machine: 0, time: 0, finishTime: 0), count: 0), count: noOfMachines)
    /// Iterate through each task
    for n in 0...(solution.count-1) {
        var task = solution[n]
        /// If the task is the first in the sequence of that job no need to check for finish time of previous task
        if task.sequence == 0 {
            /// Check if there is a task in the queue for this machine
            if let previousTask = machines[task.machine].last {
                /// Set task finish time to follow on form this task
                task.finishTime = previousTask.finishTime + task.time
            } else {
                /// If no jobs in queue then task can execute first
                task.finishTime = task.time
            }
            /// If there are previous tasks for this job find the previous task finish time and compare to finish time of last task on machine to identify earliest start time for this task
        } else {
            /// Find the finish time of the previous task
            var previousJobFinishTime = 0
            for machine in machines {
                for taskSearch in machine {
                    if taskSearch.job == task.job && taskSearch.sequence == (task.sequence-1) {
                        previousJobFinishTime = taskSearch.finishTime
                    }
                }
            }
            /// Find the finish time of the previous task on the machine
            if let previousTask = machines[task.machine].last {
                let earliestStart = previousTask.finishTime > previousJobFinishTime ? previousTask.finishTime : previousJobFinishTime
                task.finishTime = earliestStart + task.time
            } else {
                task.finishTime = previousJobFinishTime + task.time
            }
        }
        /// Add the task to the queue on that machine
        machines[task.machine].append(task)
    }
    /// Iterate through machines to identify highest finish time
    var timeToComplete = 0
    for machine in machines {
        if let lastTask = machine.last, lastTask.finishTime > timeToComplete {
            timeToComplete = lastTask.finishTime
        }
    }
    return timeToComplete
}

/// Crossover function
func orderCrossover() -> (childSolution1: [Task], childSolution2: [Task]) {
    /// Sort population in ascending order
    let sortedSolutions = solutions.sorted(by: { $0.timeToComplete < $1.timeToComplete })
    /// Select the 2 best solutions
    var firstSolution = sortedSolutions[0].solution
    var secondSolution = sortedSolutions[1].solution
    /// Find 2 random numbers in the 2nd half of the solution to create a substring
    let randomElement = Int(arc4random_uniform(UInt32(firstSolution.count)))
    let subArray1 = Array(firstSolution[randomElement...(firstSolution.count-1)])
    let subArray2 = Array(secondSolution[randomElement...(secondSolution.count-1)])
    /// Remove existing items in solution and append items from subArray
    for item in subArray1 {
        for n in 0...(secondSolution.count-1) {
            if item.job == secondSolution[n].job && item.sequence == secondSolution[n].sequence {
                secondSolution.remove(at: n)
                secondSolution.append(item)
            }
        }
    }
    for item in subArray2 {
        for n in 0...(firstSolution.count-1) {
            if item.job == firstSolution[n].job && item.sequence == firstSolution[n].sequence {
                firstSolution.remove(at: n)
                firstSolution.append(item)
            }
        }
        
    }
    firstSolution = mutation(inputSolution: firstSolution)
    secondSolution = mutation(inputSolution: secondSolution)
    return (childSolution1: firstSolution, childSolution2: secondSolution)
}

/// Find an element at random and swap it to a random position between it's current position and the position of it's predecessor task
func mutation(inputSolution: [Task]) -> [Task] {
    var solution = inputSolution
    let randomNumber = Int(arc4random_uniform(UInt32(inputSolution.count)))
    let randomElement = solution[randomNumber]
    /// If random element is the first task in a sequence start position is 0
    var startPosition = 0
    if randomElement.sequence > 0 {
        for n in 0...(solution.count-1) {
            if solution[n].job == randomElement.job && solution[n].sequence == (randomElement.sequence-1) {
                startPosition = n + 1
            }
        }
    }
    /// Move the element from it's current position to a new random position
    let newPositionRange = randomNumber - startPosition
    let newPosition = startPosition + Int(arc4random_uniform(UInt32(newPositionRange)))
    solution.remove(at: randomNumber)
    solution.insert(randomElement, at: newPosition)
    return solution
}

func JobShop() {
    var population1 = Population(timeToComplete: 0, solution: [Task(job: 0, sequence: 0, machine: 0, time: 1, finishTime: 0),
                                                                Task(job: 0, sequence: 1, machine: 2, time: 1, finishTime: 0),
                                                                Task(job: 0, sequence: 2, machine: 2, time: 3, finishTime: 0),
                                                                Task(job: 0, sequence: 3, machine: 3, time: 3, finishTime: 0),
                                                                Task(job: 1, sequence: 0, machine: 0, time: 1, finishTime: 0),
                                                                Task(job: 1, sequence: 1, machine: 3, time: 2, finishTime: 0),
                                                                Task(job: 1, sequence: 2, machine: 0, time: 2, finishTime: 0),
                                                                Task(job: 1, sequence: 3, machine: 1, time: 3, finishTime: 0),
                                                                Task(job: 1, sequence: 4, machine: 4, time: 1, finishTime: 0),
                                                                Task(job: 2, sequence: 0, machine: 1, time: 3, finishTime: 0),
                                                                Task(job: 2, sequence: 1, machine: 2, time: 4, finishTime: 0),
                                                                Task(job: 2, sequence: 2, machine: 3, time: 1, finishTime: 0),
                                                                Task(job: 2, sequence: 3, machine: 4, time: 4, finishTime: 0),
                                                                Task(job: 3, sequence: 0, machine: 2, time: 1, finishTime: 0),
                                                                Task(job: 3, sequence: 1, machine: 3, time: 1, finishTime: 0),
                                                                Task(job: 3, sequence: 2, machine: 0, time: 1, finishTime: 0),
                                                                Task(job: 3, sequence: 3, machine: 4, time: 1, finishTime: 0)])
    var population2 = Population(timeToComplete: 0, solution: [Task(job: 0, sequence: 0, machine: 0, time: 1, finishTime: 0),
                                                               Task(job: 1, sequence: 0, machine: 0, time: 1, finishTime: 0),
                                                               Task(job: 2, sequence: 0, machine: 1, time: 3, finishTime: 0),
                                                               Task(job: 3, sequence: 0, machine: 2, time: 1, finishTime: 0),
                                                               Task(job: 0, sequence: 1, machine: 2, time: 1, finishTime: 0),
                                                               Task(job: 1, sequence: 1, machine: 3, time: 2, finishTime: 0),
                                                               Task(job: 2, sequence: 1, machine: 2, time: 4, finishTime: 0),
                                                               Task(job: 3, sequence: 1, machine: 3, time: 1, finishTime: 0),
                                                               Task(job: 0, sequence: 2, machine: 2, time: 3, finishTime: 0),
                                                               Task(job: 1, sequence: 2, machine: 0, time: 2, finishTime: 0),
                                                               Task(job: 2, sequence: 2, machine: 3, time: 1, finishTime: 0),
                                                               Task(job: 3, sequence: 2, machine: 0, time: 1, finishTime: 0),
                                                               Task(job: 0, sequence: 3, machine: 3, time: 3, finishTime: 0),
                                                               Task(job: 1, sequence: 3, machine: 1, time: 3, finishTime: 0),
                                                               Task(job: 2, sequence: 3, machine: 4, time: 4, finishTime: 0),
                                                               Task(job: 3, sequence: 3, machine: 4, time: 1, finishTime: 0),
                                                               Task(job: 1, sequence: 4, machine: 4, time: 1, finishTime: 0)])
    population1.timeToComplete = fitnessFunction(solution: population1.solution)
    population2.timeToComplete = fitnessFunction(solution: population2.solution)
    solutions.append(population1)
    solutions.append(population2)
    var solutionsString = "\(population1.timeToComplete),\(population2.timeToComplete)"
    var chromosomeString = "\(solutionStringCreator(solution: population1.solution)) \(solutionStringCreator(solution: population2.solution))"
    for _ in 0...19 {
        let children = orderCrossover()
        let child1Fitness = fitnessFunction(solution: children.childSolution1)
        let child2Fitness = fitnessFunction(solution: children.childSolution2)
        let newSolution1 = Population(timeToComplete: child1Fitness, solution: children.childSolution1)
        let newSolution2 = Population(timeToComplete: child2Fitness, solution: children.childSolution2)
        solutions.append(newSolution1)
        solutions.append(newSolution2)
        solutionsString.append(",\(child1Fitness),\(child2Fitness)")
        chromosomeString.append("\(solutionStringCreator(solution: children.childSolution1)) \(solutionStringCreator(solution: children.childSolution2))")
    }
    print(solutionsString)
    print(chromosomeString)
}

/// Used to output a string that can be exported into a csv file
func solutionStringCreator(solution: [Task]) -> String {
    var string = ""
    for task in solution {
        string.append("\(task.job)\(task.machine)\(task.sequence) - ")
    }
    string.append(",")
    return string
}

JobShop()
