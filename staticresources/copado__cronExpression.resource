var cronBuilder = cronBuilder || {};

((builder) => {
    const STARTS = 'starts';
    const EVERY = 'every';
    const WEEKDAYS = 'weekdays';
    const HOURLY = 'hourly';
    const DAILY = 'daily';
    const WEEKLY = 'weekly';
    const SETTINGS = 'Settings';

    var builder = builder || {};
    var hourlySettings = hourlySettings || {};
    var dailySettings = dailySettings || {};
    var weeklySettings = weeklySettings || {};
    var selectedTab = HOURLY + SETTINGS;

    ((thisCron) => {
        const EVERY_DAY_CRON = ' 1/1 * ? *';
        var EVERY_X_HOURS = 0;
        var START_HOUR = 0;
        var START_MINUTE = 0;
        thisCron.FREQUENCY = EVERY;

        thisCron.generateCronExpression = () => {
            var cronExpression = '';
            _getValues();
            if(thisCron.FREQUENCY == EVERY) {
                cronExpression = '0 0 0/' + EVERY_X_HOURS + EVERY_DAY_CRON;
            } else if(thisCron.FREQUENCY == STARTS) {
                cronExpression = '0 ' + START_MINUTE + ' ' + START_HOUR + EVERY_DAY_CRON;
            }
            return cronExpression;
        };

        var _getValues = () => {
            var every_x_hours_hourOptions = document.getElementById('every_x_hours_hourOptions');
            var hourly_starts_at_hourOptions = document.getElementById('hourly_starts_at_hourOptions');
            var hourly_starts_at_minuteOptions = document.getElementById('hourly_starts_at_minuteOptions');
            EVERY_X_HOURS = every_x_hours_hourOptions ? every_x_hours_hourOptions.value : 0;
            START_HOUR = hourly_starts_at_hourOptions ? hourly_starts_at_hourOptions.value : 0;
            START_MINUTE = hourly_starts_at_minuteOptions ? hourly_starts_at_minuteOptions.value : 0;
        };
    })(hourlySettings);

    ((thisCron) => {
        var EVERY_X_DAYS = 0;
        var START_HOUR = 0;
        var START_MINUTE = 0;
        thisCron.FREQUENCY = EVERY;

        thisCron.generateCronExpression = () => {
            var cronExpression = '';
            _getValues();
            if(thisCron.FREQUENCY == EVERY) {
                cronExpression = '0 ' + START_MINUTE + ' ' + START_HOUR + ' 1/' + EVERY_X_DAYS + ' * ? *';
            } else if(thisCron.FREQUENCY == WEEKDAYS) {
                cronExpression = '0 ' + START_MINUTE + ' ' + START_HOUR + ' ? * MON-FRI *';
            }
            return cronExpression;
        };

        var _getValues = () => {
            var every_x_daysInput = document.getElementById('every_x_daysInput');
            var daily_starts_at_hourOptions = document.getElementById('daily_starts_at_hourOptions');
            var daily_starts_at_minuteOptions = document.getElementById('daily_starts_at_minuteOptions');
            EVERY_X_DAYS = every_x_daysInput ? every_x_daysInput.value : 0;
            START_HOUR = daily_starts_at_hourOptions ? daily_starts_at_hourOptions.value : 0;
            START_MINUTE = daily_starts_at_minuteOptions ? daily_starts_at_minuteOptions.value : 0;
        };
    })(dailySettings);

    ((thisCron) => {
        var START_HOUR = 0;
        var START_MINUTE = 0;
        var DAYS_OF_WEEK = '';

        thisCron.generateCronExpression = () => {
            var cronExpression = '';
            _getValues();
            cronExpression = '0 ' + START_MINUTE + ' ' + START_HOUR + ' ? * ' + DAYS_OF_WEEK + ' *';
            return cronExpression;
        };

        var _getValues = () => {
            var weekly_starts_at_hourOptions = document.getElementById('weekly_starts_at_hourOptions');
            var weekly_starts_at_minuteOptions = document.getElementById('weekly_starts_at_minuteOptions');
            START_HOUR = weekly_starts_at_hourOptions ? weekly_starts_at_hourOptions.value : 0;
            START_MINUTE = weekly_starts_at_minuteOptions ? weekly_starts_at_minuteOptions.value : 0;
            DAYS_OF_WEEK = _getDaysOfWeek();
        };

        var _getDaysOfWeek = () => {
            var dayCheckboxes = [];
            var that = this;
            $copado(".dayCheckbox:checked").each((index, checkbox) => {
                dayCheckboxes.push($copado(checkbox).val());
            });
            return dayCheckboxes.join(',');
        };
    })(weeklySettings);

    var _getSelectedSetting = () => {
        if(selectedTab == HOURLY + SETTINGS) {
            return hourlySettings;
        } else if(selectedTab == DAILY + SETTINGS) {
            return dailySettings;
        } else if(selectedTab == WEEKLY + SETTINGS) {
            return weeklySettings;
        }
        return null;
    };

    builder.setSelectedTab = (thisTab) => {
        selectedTab = thisTab;
        _switchTab();
    };

    var _switchTab = (thisTab) => {
        var settingContainers = document.getElementsByClassName('settingsContainer');
        if(settingContainers) {
            for(var i = 0; i < settingContainers.length; i++) {
                var thisContainer = settingContainers[i];
                if(thisContainer.id == selectedTab) {
                    thisContainer.style.display = 'block';
                } else {
                    thisContainer.style.display = 'none';
                }
            }
        }
    }

    builder.setFrequency = (frequency, name) => {
        if(frequency == HOURLY) {
            hourlySettings.FREQUENCY = name;
        } else if(frequency == DAILY) {
            dailySettings.FREQUENCY = name;
        }
    };

    var _generateCronExpression = () => {
        var setting = _getSelectedSetting();
    	console.assert(setting != null, 'Failed to automatically generate cron expression due to an internal error.');
        var cronExpression = setting.generateCronExpression();
    	$copado('input[id$="cronExpressionInput"]').val(cronExpression);
    };

    builder.setCronExpressionAndSave = () => {
        var cronExpression = document.querySelector('.cronExpression');
        if(cronExpression) {
            setCronExpressionValue(cronExpression.value);
        }
    };

    var _setControllerRadio = (thisInput) => {
        var radioId = $copado(thisInput).data('controller-element');
        var cronRadio = document.getElementById(radioId);
        if(cronRadio) {
            cronRadio.click();
        }
    };

    $copado(document).ready(() => {
        $copado('input[type="radio"].cronRadio,input[type="number"].cronInput,input[type="checkbox"].dayCheckbox').on('click', function() {
            try {
                if(this.type != 'radio') {
                    _setControllerRadio(this);
                }
                _generateCronExpression();
            } catch(error) {
                console.error('error: ' + error);
            }
        });
        $copado('select.cronInput').on('change', function() {
            try {
                _setControllerRadio(this);
                _generateCronExpression();
            } catch(error) {
                console.error('error: ' + error);
            }
        });
    });
})(cronBuilder);