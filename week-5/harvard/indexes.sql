CREATE INDEX "enrollments_student_course_idx" ON "enrollments" ("student_id", "course_id");
CREATE INDEX "courses_semester_dept_num_idx" ON "courses" ("semester", "department", "number");
CREATE INDEX "satisfies_course_requirement_idx" ON "satisfies" ("course_id", "requirement_id");