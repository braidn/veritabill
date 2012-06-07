#! /usr/bin/Rscript

# We assume that there are two classes of task, "long" and "short". Long tasks
# take an unknown amount of time, but are normally distributed with a mean of
# 48 work hours and standard deviation of 8 hours. Short tasks take an unknown
# amount of time, normally distributed with a mean of 4 work hours and
# variance of 2 hours. Most tasks (80%) are short.
#
# Our timesheets are in 30-minute chunks -- so task is shorter than that.
#
# Each of our users is equally skilled at completing tasks -- but they aren't
# all as good at estimating the time tasks will take. Sometimes they mistake
# short tasks for long tasks (and vice verse -- about 5% of the time). Some of
# them are optimists, some of them are pessimists, and some of them are more
# uncertain than others. 

users <- list(
  # Yvette is a pessimist; she thinks tasks will take twice as long as they
  # really do.
  Yvette = list(
    estimate = c(2, 1)
  ),
  # Tom often mistakes short tasks for long tasks -- about three times as
  # often as his coworkers.
  Tom = list(
    misclassify = c(3, 1)
  ),
  # Jim is an optimist at the start of his work day, and a pessimist at the
  # end of the day.
  Jim = list(
    morning.estimate = c(0.75, 0.75),
    afternoon.estimate = c(1.5, 1.5)
  ),
  # Cindy's estimates have a lot of variance.
  Cindy = list(
    estimate = c(1, 2)
  ),
  # Evelyn overestimates the time harder tasks will take, and underestimates
  # the time shorter tasks will take. 
  Evelyn = list(
    short.estimate = c(0.5, 1),
    long.estimate = c(2, 1)
  )
)

# Users estimate the time tasks will take at different times. They each
# perform tasks for all of the firm's clients.
days <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday")
times <- c("Morning", "Lunchtime", "Afternoon")
clients <- c("OCP Inc.", "Cyberdyne Systems", "Weyland-Yutani", "Tyrell",
  "Mooby's Family Restaurants")

# We seed the time tracker with 1000 tasks. About 80% of the tasks are short.
n <- 1000
short.tasks <- 0.8
task.class <- replicate(n, if (runif(1) < short.tasks) "short" else "long")

# We measure tasks in units of 30 minutes; no task takes less than 30 minutes.
# Users misclassify about 5% of tasks.

misclassify <- 0.05
tasks <- data.frame(
  class = task.class,
  user = sample(names(users), n, replace = TRUE),
  day = sample(days, n, replace = TRUE),
  time = sample(times, n, replace = TRUE),
  client = sample(clients, n, replace = TRUE),
  true.time = sapply(task.class, function (t) {
    max(1, if (t == "short") round(rnorm(1, 8, 4)) else round(rnorm(1, 96, 16)))})
)

tasks <- cbind(tasks, estimate = sapply(1:(dim(tasks)[1]), function (i) {
  t <- tasks[i,"class"]
  u <- users[tasks[i,"user"]]
  time <- tasks[i, "time"]
  misclassify <- misclassify * (if ('misclassify' %in% u) u['misclassify'] else 1)
  if (runif(1) < misclassify) {
    t <- (if (t == "short") "long" else "short")
  }
  params <- (if (t == "short") c(8, 4) else c(96, 16)) * (if ('estimate' %in% u) u['estimate'] else 1)

  # adjust for user biases
  if (time == "morning") {
    params <- params * (if ('morning.estimate' %in% u) u['morning.estimate'] else 1) 
  } else if (time == "afternoon") {
    params <- params * (if ('afternoon.estimate' %in% u) u['afternoon.estimate'] else 1)
  }
  if (t == "short") {
    params <- params * (if ('short.estimate' %in% u) u['short.estimate'] else 1)
  } else {
    params <- params * (if ('long.estimate' %in% u) u['long.estimate'] else 1)
  }

  estimate <- max(1, round(rnorm(1, params[1], params[2])))
  estimate
}))

write.csv(tasks, "seed_data.csv")
