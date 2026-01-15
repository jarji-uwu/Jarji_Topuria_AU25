PASSING_GRADE = 8

class Trainee:
    def __init__(self, name, surname):
        self.name = name
        self.surname = surname
        self.visited_lectures = 0
        self.missed_lectures = 0
        self.done_home_tasks = 0
        self.missed_home_tasks = 0
        self.mark = 0

    # Task 2
    def visit_lecture(self):
        self.visited_lectures += 1
        self._add_points(1)  # adds 1 to mark

    # Task 3
    def do_homework(self):
        self.done_home_tasks += 1
        self._add_points(2)  # adds 2 to mark

    # Task 4
    def miss_lecture(self):
        self.missed_lectures += 1
        self._subtract_points(1)  # subtracts 1 from mark

    # Task 5
    def miss_homework(self):
        self.missed_home_tasks += 1
        self._subtract_points(2)  # subtracts 2 from mark

    # Task 6
    def _add_points(self, points: int):
        self.mark += points
        if self.mark > 10:       # mark cannot exceed 10
            self.mark = 10

    # Task 7
    def _subtract_points(self, points: int):
        self.mark -= points
        if self.mark < 0:        # mark cannot go below 0
            self.mark = 0

    # Task 8
    def is_passed(self):
        if self.mark >= PASSING_GRADE:
            print("Good job!")
        else:
            missing = PASSING_GRADE - self.mark
            print(f"You need to get {missing} more points. Try to do your best!")

    # Optional: nice string representation
    def __str__(self):
        status = (
            f"Trainee {self.name.title()} {self.surname.title()}:\n"
            f"done homework {self.done_home_tasks} points;\n"
            f"missed homework {self.missed_home_tasks} points;\n"
            f"visited lectures {self.visited_lectures} points;\n"
            f"missed lectures {self.missed_lectures} points;\n"
            f"current mark {self.mark};\n"
        )
        return status