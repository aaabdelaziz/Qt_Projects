#pragma once

#include <QObject>
#include <QString>
#include <QTimer>
#include <QVariantList>

struct CurlMetrics
{
    double elbow_angle_degrees{165.0};
    double biceps_activation{0.08};
    double form_score{92.0};
    double tempo_progress{0.0};
    int calories{0};
};

class BicepsWorkoutController final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString sessionState READ sessionState NOTIFY sessionStateChanged)
    Q_PROPERTY(bool running READ running NOTIFY sessionStateChanged)
    Q_PROPERTY(bool manualMode READ manualMode WRITE setManualMode NOTIFY manualModeChanged)
    Q_PROPERTY(QString elapsedTime READ elapsedTime NOTIFY elapsedChanged)
    Q_PROPERTY(QString tempoPhase READ tempoPhase NOTIFY metricsChanged)
    Q_PROPERTY(QString coachCue READ coachCue NOTIFY coachCueChanged)
    Q_PROPERTY(int movementDirection READ movementDirection NOTIFY movementDirectionChanged)
    Q_PROPERTY(double elbowAngle READ elbowAngle NOTIFY metricsChanged)
    Q_PROPERTY(double activation READ activation NOTIFY metricsChanged)
    Q_PROPERTY(double formScore READ formScore NOTIFY metricsChanged)
    Q_PROPERTY(double tempoProgress READ tempoProgress NOTIFY metricsChanged)
    Q_PROPERTY(int currentRep READ currentRep NOTIFY repChanged)
    Q_PROPERTY(int targetReps READ targetReps NOTIFY targetChanged)
    Q_PROPERTY(int currentSet READ currentSet NOTIFY setChanged)
    Q_PROPERTY(int targetSets READ targetSets NOTIFY targetChanged)
    Q_PROPERTY(int selectedRounds READ selectedRounds WRITE setSelectedRounds NOTIFY targetChanged)
    Q_PROPERTY(int pushesPerRound READ pushesPerRound WRITE setPushesPerRound NOTIFY targetChanged)
    Q_PROPERTY(int completedRounds READ completedRounds NOTIFY setHistoryChanged)
    Q_PROPERTY(int totalPushesCompleted READ totalPushesCompleted NOTIFY repChanged)
    Q_PROPERTY(int loadKg READ loadKg NOTIFY loadChanged)
    Q_PROPERTY(int calories READ calories NOTIFY metricsChanged)
    Q_PROPERTY(QVariantList setHistory READ setHistory NOTIFY setHistoryChanged)

public:
    enum class SessionState {
        ready,
        running,
        paused,
        complete
    };
    Q_ENUM(SessionState)

    explicit BicepsWorkoutController(QObject* parent = nullptr);

    QString sessionState() const;
    bool running() const noexcept;
    bool manualMode() const noexcept;
    QString elapsedTime() const;
    QString tempoPhase() const;
    QString coachCue() const;
    int movementDirection() const noexcept;
    double elbowAngle() const noexcept;
    double activation() const noexcept;
    double formScore() const noexcept;
    double tempoProgress() const noexcept;
    int currentRep() const noexcept;
    int targetReps() const noexcept;
    int currentSet() const noexcept;
    int targetSets() const noexcept;
    int selectedRounds() const noexcept;
    int pushesPerRound() const noexcept;
    int completedRounds() const noexcept;
    int totalPushesCompleted() const noexcept;
    int loadKg() const noexcept;
    int calories() const noexcept;
    QVariantList setHistory() const;

    Q_INVOKABLE void start();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void resume();
    Q_INVOKABLE void reset();
    Q_INVOKABLE void increaseLoad();
    Q_INVOKABLE void decreaseLoad();
    Q_INVOKABLE void setManualAngle(double angle_degrees);
    Q_INVOKABLE void curlUp();
    Q_INVOKABLE void lowerDown();
    Q_INVOKABLE void stopArm();
    void setManualMode(bool manual_mode);
    void setSelectedRounds(int rounds);
    void setPushesPerRound(int pushes);

signals:
    void sessionStateChanged();
    void manualModeChanged();
    void elapsedChanged();
    void metricsChanged();
    void coachCueChanged();
    void movementDirectionChanged();
    void repChanged();
    void setChanged();
    void targetChanged();
    void loadChanged();
    void setHistoryChanged();
    void roundCompleted(const QString& message);

private:
    struct TrainingSet
    {
        int set_number{1};
        int reps{0};
        int load_kg{14};
        double average_form_score{0.0};
    };

    void tick();
    void updateGuidedMotion();
    void updateButtonDrivenMotion();
    void updateDerivedMetrics(double normalized_curl);
    void detectRep(double normalized_curl);
    void completeCurrentSet();
    void clearWorkoutProgress();
    void ensureRunningFromControl();
    QString roundCompletionMessage() const;
    void updateSessionState(SessionState next_state);
    void updateCoachCue(const QString& next_cue);
    static QString formatDuration(int seconds);

    QTimer timer_;
    SessionState state_{SessionState::ready};
    CurlMetrics metrics_;
    QVariantList set_history_;
    QString tempo_phase_{"Ready"};
    QString coach_cue_{"Choose a load and start the guided biceps curl set."};
    int elapsed_seconds_{0};
    int current_rep_{0};
    int target_reps_{10};
    int current_set_{1};
    int target_sets_{3};
    int load_kg_{14};
    int total_pushes_completed_{0};
    double simulation_seconds_{0.0};
    double form_score_total_{0.0};
    int form_score_samples_{0};
    bool manual_mode_{false};
    bool rep_peak_seen_{false};
    int movement_direction_{0};
};
