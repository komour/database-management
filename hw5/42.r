π{StudentId, StudentName, GroupId}(σ{CourseName = :CourseName}(Students ⋈ Courses ⋈ Plan)) ∖ π{StudentId, StudentName, GroupId}(σ{CourseName = :CourseName}(Students ⋈ Courses ⋈ Marks ⋈ Plan))