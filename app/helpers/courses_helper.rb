# frozen_string_literal: true

module CoursesHelper
  # Builds and sorts workout items for display in the courses workouts tab.
  # By default, items are sorted in due date order (earliest due date first,
  # workouts without a due date placed at the end, tie-broken by name).
  def course_workout_items(course_offerings, current_user, is_student, now = Time.zone.now)
    return [] if course_offerings.blank?

    offerings_list = course_offerings.to_a
    all_wos = offerings_list.flat_map(&:workout_offerings)

    # Base list of unique workout offerings to display
    candidate_wos = if is_student
      all_wos.select { |wo| current_user && wo.can_be_seen_by?(current_user) }.uniq(&:workout_id)
    else
      all_wos.uniq(&:workout_id)
    end

    items = candidate_wos.map do |wo|
      workout = wo.workout
      next unless workout

      workout_offerings_for_wo = all_wos.select { |o| o.workout_id == wo.workout_id }
      if is_student && current_user
        workout_offerings_for_wo = workout_offerings_for_wo.select { |o| o.can_be_seen_by?(current_user) }
        workout_offerings_for_wo = [wo] if workout_offerings_for_wo.empty?
      end

      # Opening dates (min from date)
      opening_dates = workout_offerings_for_wo.map do |o|
        (is_student && current_user) ? o.opening_date_for(current_user) : o.opening_date
      end.compact
      min_from = opening_dates.min

      # Closed dates (max closed date / until date)
      closed_dates = workout_offerings_for_wo.map do |o|
        if is_student && current_user
          o.hard_deadline_for(current_user) || o.extension_for(current_user)&.soft_deadline || o.soft_deadline
        else
          o.hard_deadline || o.soft_deadline
        end
      end.compact
      max_closed = closed_dates.max

      # Due dates (soft deadline or hard deadline)
      due_dates = workout_offerings_for_wo.map do |o|
        if is_student && current_user
          o.extension_for(current_user)&.soft_deadline || o.soft_deadline || o.hard_deadline_for(current_user) || o.hard_deadline
        else
          o.soft_deadline || o.hard_deadline
        end
      end.compact
      due_date = due_dates.min

      # Publication status
      is_published = workout_offerings_for_wo.any?(&:published)
      is_unpublished = workout_offerings_for_wo.any? { |o| !o.published }

      # State calculations
      is_open = (min_from.nil? || now >= min_from) && (max_closed.nil? || now <= max_closed)
      is_past = max_closed.present? && now > max_closed
      is_future = min_from.present? && now < min_from
      is_past_due = due_date.present? && now > due_date

      sort_key = [due_date ? 0 : 1, due_date || Time.zone.at(0), workout.name.downcase]

      {
        offering: wo,
        workout: workout,
        min_from: min_from,
        max_closed: max_closed,
        due_date: due_date,
        is_published: is_published,
        is_unpublished: is_unpublished,
        is_open: is_open,
        is_past: is_past,
        is_future: is_future,
        is_past_due: is_past_due,
        sort_key: sort_key,
        data: {
          workout_name: workout.name.downcase,
          due_date: (due_date ? due_date.to_i : 9999999999),
          opening_date: (min_from ? min_from.to_i : 9999999999),
          closed_date: (max_closed ? max_closed.to_i : 9999999999),
          is_published: is_published.to_s,
          is_unpublished: is_unpublished.to_s,
          is_open: is_open.to_s,
          is_past: is_past.to_s,
          is_future: is_future.to_s,
          is_past_due: is_past_due.to_s
        }
      }
    end.compact

    items.sort_by { |item| item[:sort_key] }
  end
end
