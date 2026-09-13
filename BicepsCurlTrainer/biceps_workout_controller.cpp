#include "biceps_workout_controller.h"

#include <QVariantMap>
#include <QtMath>

#include <algorithm>

namespace {
constexpr double tick_seconds{0.05};
constexpr int tick_milliseconds{50};
constexpr int min_load_kg{2};
constexpr int max_load_kg{40};
constexpr double extended_angle{165.0};
constexpr double contracted_angle{48.0};
constexpr double rep_period_seconds{4.0};
constexpr double button_angle_step{4.5};
constexpr int min_rounds{1};
constexpr int max_rounds{8};
constexpr int min_pushes_per_round{1};
constexpr int max_pushes_per_round{30};
}

BicepsWorkoutController::BicepsWorkoutController(QObject* parent)
    : QObject{parent}
{
    timer_.setInterval(tick_milliseconds);
    connect(&timer_, &QTimer::timeout, this, &BicepsWorkoutController::tick);
}

QString BicepsWorkoutController::sessionState() const
{
    switch (state_) {
    case SessionState::ready:
        return "Ready";
    case SessionState::running:
        return "Running";
    case SessionState::paused:
        return "Paused";
    case SessionState::complete:
        return "Complete";
    }
    return "Unknown";
}

bool BicepsWorkoutController::running() const noexcept
{
    return state_ == SessionState::running;
}

bool BicepsWorkoutController::manualMode() const noexcept
{
    return manual_mode_;
}

QString BicepsWorkoutController::elapsedTime() const
{
    return formatDuration(elapsed_seconds_);
}

QString BicepsWorkoutController::tempoPhase() const
{
    return tempo_phase_;
}

QString BicepsWorkoutController::coachCue() const
{
    return coach_cue_;
}

int BicepsWorkoutController::movementDirection() const noexcept
{
    return movement_direction_;
}

double BicepsWorkoutController::elbowAngle() const noexcept
{
    return metrics_.elbow_angle_degrees;
}

double BicepsWorkoutController::activation() const noexcept
{
    return metrics_.biceps_activation;
}

double BicepsWorkoutController::formScore() const noexcept
{
    return metrics_.form_score;
}

double BicepsWorkoutController::tempoProgress() const noexcept
{
    return metrics_.tempo_progress;
}

int BicepsWorkoutController::currentRep() const noexcept
{
    return current_rep_;
}

int BicepsWorkoutController::targetReps() const noexcept
{
    return target_reps_;
}

int BicepsWorkoutController::currentSet() const noexcept
{
    return current_set_;
}

int BicepsWorkoutController::targetSets() const noexcept
{
    return target_sets_;
}

int BicepsWorkoutController::selectedRounds() const noexcept
{
    return target_sets_;
}

int BicepsWorkoutController::pushesPerRound() const noexcept
{
    return target_reps_;
}

int BicepsWorkoutController::completedRounds() const noexcept
{
    return static_cast<int>(set_history_.size());
}

int BicepsWorkoutController::totalPushesCompleted() const noexcept
{
    return total_pushes_completed_;
}

int BicepsWorkoutController::loadKg() const noexcept
{
    return load_kg_;
}

int BicepsWorkoutController::calories() const noexcept
{
    return metrics_.calories;
}

QVariantList BicepsWorkoutController::setHistory() const
{
    return set_history_;
}

void BicepsWorkoutController::start()
{
    if (state_ == SessionState::complete) {
        reset();
    }

    updateSessionState(SessionState::running);
    updateCoachCue(manual_mode_ ? "Hold Curl Up and Lower Down to control the arm." : "Follow the guided curl animation and keep the elbow fixed.");
    timer_.start();
}

void BicepsWorkoutController::pause()
{
    if (state_ != SessionState::running) {
        return;
    }

    timer_.stop();
    updateSessionState(SessionState::paused);
    updateCoachCue("Paused. Keep posture tall before resuming.");
}

void BicepsWorkoutController::resume()
{
    if (state_ != SessionState::paused) {
        return;
    }

    updateSessionState(SessionState::running);
    if (current_rep_ >= target_reps_) {
        completeCurrentSet();
        if (state_ == SessionState::complete) {
            return;
        }
    }

    updateCoachCue(manual_mode_ ? "Resume manual curls with a controlled range." : "Resume guided curls and match the tempo.");
    timer_.start();
}

void BicepsWorkoutController::reset()
{
    timer_.stop();
    state_ = SessionState::ready;
    clearWorkoutProgress();
    emit sessionStateChanged();
    emit metricsChanged();
    emit coachCueChanged();
    emit setHistoryChanged();
}

void BicepsWorkoutController::increaseLoad()
{
    const int next_load{std::min(max_load_kg, load_kg_ + 2)};
    if (next_load == load_kg_) {
        return;
    }

    load_kg_ = next_load;
    emit loadChanged();
}

void BicepsWorkoutController::decreaseLoad()
{
    const int next_load{std::max(min_load_kg, load_kg_ - 2)};
    if (next_load == load_kg_) {
        return;
    }

    load_kg_ = next_load;
    emit loadChanged();
}

void BicepsWorkoutController::setSelectedRounds(int rounds)
{
    if (state_ == SessionState::complete) {
        return;
    }

    const int minimum_rounds{state_ == SessionState::ready ? min_rounds : std::max(min_rounds, current_set_)};
    const int next_rounds{std::clamp(rounds, minimum_rounds, max_rounds)};
    if (next_rounds == target_sets_) {
        return;
    }

    target_sets_ = next_rounds;
    if (state_ == SessionState::ready) {
        clearWorkoutProgress();
        updateCoachCue("Training plan updated. Start when ready.");
    } else if (state_ == SessionState::paused) {
        updateCoachCue("Plan updated. Continue from your current progress.");
    }
    emit targetChanged();
    emit metricsChanged();
    emit setHistoryChanged();
}

void BicepsWorkoutController::setPushesPerRound(int pushes)
{
    if (state_ == SessionState::complete) {
        return;
    }

    const int next_pushes{std::clamp(pushes, min_pushes_per_round, max_pushes_per_round)};
    if (next_pushes == target_reps_) {
        return;
    }

    target_reps_ = next_pushes;
    if (state_ == SessionState::ready) {
        clearWorkoutProgress();
        updateCoachCue("Push target updated. Start when ready.");
    } else if (state_ == SessionState::paused) {
        updateCoachCue("Push target updated. Continue from your current count.");
    }
    emit targetChanged();
    emit metricsChanged();
    emit setHistoryChanged();
}

void BicepsWorkoutController::clearWorkoutProgress()
{
    metrics_ = CurlMetrics{};
    set_history_.clear();
    tempo_phase_ = "Ready";
    coach_cue_ = "Choose a load and start the guided biceps curl set.";
    elapsed_seconds_ = 0;
    current_rep_ = 0;
    current_set_ = 1;
    total_pushes_completed_ = 0;
    simulation_seconds_ = 0.0;
    form_score_total_ = 0.0;
    form_score_samples_ = 0;
    rep_peak_seen_ = false;
    movement_direction_ = 0;

    emit elapsedChanged();
    emit movementDirectionChanged();
    emit repChanged();
    emit setChanged();
}

void BicepsWorkoutController::ensureRunningFromControl()
{
    // Manual controls (arrow keys, hold-buttons, the elbow slider) should
    // resume a paused session the same way the Pause/Continue button does,
    // instead of forcing a fresh start() that skips resume()'s
    // rep-completion bookkeeping.
    if (state_ == SessionState::paused) {
        resume();
    } else if (state_ != SessionState::running) {
        start();
    }
}

void BicepsWorkoutController::setManualAngle(double angle_degrees)
{
    if (!manual_mode_ || state_ == SessionState::complete) {
        return;
    }

    ensureRunningFromControl();
    if (state_ != SessionState::running) {
        return;
    }

    const double clamped_angle{std::clamp(angle_degrees, contracted_angle, extended_angle)};
    const double normalized_curl{(extended_angle - clamped_angle) / (extended_angle - contracted_angle)};
    metrics_.elbow_angle_degrees = clamped_angle;
    updateDerivedMetrics(normalized_curl);
    detectRep(normalized_curl);
    emit metricsChanged();
}

void BicepsWorkoutController::curlUp()
{
    if (state_ == SessionState::complete) {
        return;
    }

    setManualMode(true);
    ensureRunningFromControl();
    if (state_ != SessionState::running) {
        return;
    }

    if (movement_direction_ == 1) {
        return;
    }

    movement_direction_ = 1;
    tempo_phase_ = "Curl up";
    updateCoachCue("Curling up. Keep your elbow fixed and squeeze at the top.");
    emit movementDirectionChanged();
    emit metricsChanged();
}

void BicepsWorkoutController::lowerDown()
{
    if (state_ == SessionState::complete) {
        return;
    }

    setManualMode(true);
    ensureRunningFromControl();
    if (state_ != SessionState::running) {
        return;
    }

    if (movement_direction_ == -1) {
        return;
    }

    movement_direction_ = -1;
    tempo_phase_ = "Lower slow";
    updateCoachCue("Lowering down. Control the negative and reach full extension.");
    emit movementDirectionChanged();
    emit metricsChanged();
}

void BicepsWorkoutController::stopArm()
{
    if (movement_direction_ == 0) {
        return;
    }

    movement_direction_ = 0;
    tempo_phase_ = "Hold";
    updateCoachCue("Hold position. Press up or down to continue the rep.");
    emit movementDirectionChanged();
    emit metricsChanged();
}

void BicepsWorkoutController::setManualMode(bool manual_mode)
{
    if (state_ == SessionState::complete && manual_mode) {
        return;
    }

    if (manual_mode_ == manual_mode) {
        return;
    }

    manual_mode_ = manual_mode;
    movement_direction_ = 0;
    tempo_phase_ = manual_mode_ ? "Manual" : "Ready";
    rep_peak_seen_ = false;
    updateCoachCue(manual_mode_ ? "Manual mode: hold Curl Up and Lower Down to move the arm." : "Guided mode: use Start to follow the animation.");
    emit manualModeChanged();
    emit movementDirectionChanged();
    emit metricsChanged();
}

void BicepsWorkoutController::tick()
{
    if (state_ != SessionState::running) {
        return;
    }

    simulation_seconds_ += tick_seconds;
    const int next_elapsed{static_cast<int>(simulation_seconds_)};
    if (next_elapsed != elapsed_seconds_) {
        elapsed_seconds_ = next_elapsed;
        emit elapsedChanged();
    }

    if (!manual_mode_) {
        updateGuidedMotion();
    } else {
        updateButtonDrivenMotion();
    }

    metrics_.calories = static_cast<int>(current_set_ * load_kg_ * 0.18 + current_rep_ * load_kg_ * 0.08);
    emit metricsChanged();
}

void BicepsWorkoutController::updateGuidedMotion()
{
    const double rep_position{std::fmod(simulation_seconds_, rep_period_seconds) / rep_period_seconds};
    double normalized_curl{0.0};

    if (rep_position < 0.45) {
        tempo_phase_ = "Curl up";
        normalized_curl = rep_position / 0.45;
    } else if (rep_position < 0.62) {
        tempo_phase_ = "Squeeze";
        normalized_curl = 1.0;
    } else {
        tempo_phase_ = "Lower slow";
        normalized_curl = 1.0 - ((rep_position - 0.62) / 0.38);
    }

    metrics_.tempo_progress = rep_position;
    metrics_.elbow_angle_degrees = extended_angle - normalized_curl * (extended_angle - contracted_angle);
    updateDerivedMetrics(normalized_curl);
    detectRep(normalized_curl);
}

void BicepsWorkoutController::updateButtonDrivenMotion()
{
    if (movement_direction_ == 0) {
        return;
    }

    const double angle_delta{movement_direction_ > 0 ? -button_angle_step : button_angle_step};
    const double next_angle{std::clamp(metrics_.elbow_angle_degrees + angle_delta, contracted_angle, extended_angle)};
    const double normalized_curl{(extended_angle - next_angle) / (extended_angle - contracted_angle)};

    metrics_.elbow_angle_degrees = next_angle;
    metrics_.tempo_progress = normalized_curl;
    updateDerivedMetrics(normalized_curl);
    detectRep(normalized_curl);

    const bool reached_top{next_angle <= contracted_angle + 0.5};
    const bool reached_bottom{next_angle >= extended_angle - 0.5};
    if ((movement_direction_ > 0 && reached_top) || (movement_direction_ < 0 && reached_bottom)) {
        stopArm();
    }
}

void BicepsWorkoutController::updateDerivedMetrics(double normalized_curl)
{
    const double load_factor{static_cast<double>(load_kg_) / static_cast<double>(max_load_kg)};
    metrics_.biceps_activation = std::clamp(0.12 + normalized_curl * 0.72 + load_factor * 0.18, 0.0, 1.0);

    const double ideal_angle_bonus{1.0 - std::abs(normalized_curl - 0.82) * 0.45};
    const double load_penalty{std::max(0.0, load_factor - 0.55) * 18.0};
    metrics_.form_score = std::clamp(88.0 + ideal_angle_bonus * 9.0 - load_penalty, 55.0, 99.0);

    form_score_total_ += metrics_.form_score;
    ++form_score_samples_;

    if (normalized_curl > 0.82) {
        updateCoachCue("Squeeze the biceps at the top without swinging the shoulder.");
    } else if (normalized_curl < 0.18) {
        updateCoachCue("Reach full extension, then curl without moving the elbow forward.");
    } else if (metrics_.form_score < 76.0) {
        updateCoachCue("Load is challenging. Slow down and keep the wrist neutral.");
    }
}

void BicepsWorkoutController::detectRep(double normalized_curl)
{
    if (normalized_curl > 0.9 && !rep_peak_seen_) {
        rep_peak_seen_ = true;
    }

    if (normalized_curl < 0.16 && rep_peak_seen_) {
        rep_peak_seen_ = false;
        ++current_rep_;
        ++total_pushes_completed_;
        emit repChanged();
        updateCoachCue(QString{"Push %1 of %2 completed. Smooth control."}.arg(current_rep_).arg(target_reps_));

        if (current_rep_ >= target_reps_) {
            completeCurrentSet();
        }
    }
}

void BicepsWorkoutController::completeCurrentSet()
{
    const double average_form{form_score_samples_ == 0 ? 0.0 : form_score_total_ / static_cast<double>(form_score_samples_)};

    QVariantMap row;
    row.insert("setNumber", current_set_);
    row.insert("reps", current_rep_);
    row.insert("loadKg", load_kg_);
    row.insert("formScore", average_form);
    set_history_.append(row);
    emit setHistoryChanged();

    const QString completion_message{roundCompletionMessage()};
    emit roundCompleted(completion_message);

    if (current_set_ >= target_sets_) {
        timer_.stop();
        movement_direction_ = 0;
        tempo_phase_ = "Complete";
        updateSessionState(SessionState::complete);
        updateCoachCue("Workout complete. Great biceps session: log the result and recover.");
        emit movementDirectionChanged();
        emit metricsChanged();
        return;
    }

    ++current_set_;
    current_rep_ = 0;
    form_score_total_ = 0.0;
    form_score_samples_ = 0;
    rep_peak_seen_ = false;
    updateCoachCue(completion_message);
    emit setChanged();
    emit repChanged();
}

QString BicepsWorkoutController::roundCompletionMessage() const
{
    switch ((current_set_ - 1) % 4) {
    case 0:
        return QString{"Perfect! Round %1 completed."}.arg(current_set_);
    case 1:
        return QString{"Strong work! Round %1 is done."}.arg(current_set_);
    case 2:
        return QString{"Excellent control! Round %1 completed."}.arg(current_set_);
    default:
        return QString{"Great push! Round %1 finished."}.arg(current_set_);
    }
}

void BicepsWorkoutController::updateSessionState(SessionState next_state)
{
    if (state_ == next_state) {
        return;
    }

    state_ = next_state;
    emit sessionStateChanged();
}

void BicepsWorkoutController::updateCoachCue(const QString& next_cue)
{
    if (coach_cue_ == next_cue) {
        return;
    }

    coach_cue_ = next_cue;
    emit coachCueChanged();
}

QString BicepsWorkoutController::formatDuration(int seconds)
{
    const int minutes{seconds / 60};
    const int remaining_seconds{seconds % 60};
    return QString{"%1:%2"}
        .arg(minutes, 2, 10, QLatin1Char{'0'})
        .arg(remaining_seconds, 2, 10, QLatin1Char{'0'});
}
