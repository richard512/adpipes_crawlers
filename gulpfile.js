var gulp = require('gulp'),
    mocha = require('gulp-mocha'),
    blanket = require('gulp-blanket-mocha'),
    coffee = require('gulp-coffee'),
    changed = require('gulp-changed'),
    gutil = require('gulp-util'),
    coffeelint = require('gulp-coffeelint'),
    moment = require('moment');

require('coffee-script/register');

gulp.task('spec', function () {
    require('coffee-script/register');
    require('coffee-coverage').register({path: 'relative', basePath: __dirname + '/src', initAll: true});
    return gulp.src('spec/**/*.spec.coffee', {read: false})
        .pipe(mocha({reporter: 'spec'}))
//        .on('end', function () {
//            gulp.src('src/**/*.coffee')
//                .pipe(blanket({instrument: ['*'], captureFile: 'coverage.html', reporter: 'html-cov'}));
//        });
});

gulp.task('build', function () {
    return gulp.src('src/**/*.coffee')
        .pipe(coffee({bare: true}).on('error', gutil.log))
        .pipe(gulp.dest('./dist'));
});

gulp.task('lint', function () {
    return gulp.src('src/**/*.coffee')
        .pipe(coffeelint('coffeelint.json'))
        .pipe(coffeelint.reporter());
});

gulp.task('watch', function () {
    gulp.watch(["src/**/*.coffee"], ['spec', 'lint', 'build']);
});

gulp.task('default', ['watch']);

gulp.task('run', function (cb) {
    var persister = require('./src/persister');
    var argv = require('yargs').argv;
    var conditions = {}, start_date = null, end_date = null;
    var time_type = "remote";

    if (argv.name) {
        conditions = { where: {name: argv.name}};
    }
    if (argv.id) {
        conditions = { where: {id: argv.id} };
    }
    if (argv.daysAgo) {
        start_date = moment().subtract(argv.daysAgo, 'days').startOf('day').format("YYYY-MM-DD HH:mm")
        end_date = moment().subtract(argv.daysAgo, 'days').endOf('day').format("YYYY-MM-DD HH:mm")
    }
    else if (argv.startDate) {
        //only date, without time yet
        start_date = moment(argv.startDate).format("YYYY-MM-DD HH:mm")
        if (argv.endDate) {
            end_date = moment(argv.endDate).endOf('day').format("YYYY-MM-DD HH:mm")
        }
        else {
            end_date = moment(start_date).endOf('day').format("YYYY-MM-DD HH:mm")
        }
    }
    else if (argv.days) {
        //if (argv.days>1) var daysAgo = argv.days-1;
        //lse var daysAgo=0;
        start_date = moment().subtract(argv.days, 'days').startOf('day').format("YYYY-MM-DD HH:mm")
        end_date = moment().subtract(1, 'days').endOf('day').format("YYYY-MM-DD HH:mm")
        console.log(start_date);
    }
    else if (argv.hours) {
        time_type = 'local'
        start_date = moment().subtract(argv.hours, 'hours').startOf('hours').format("YYYY-MM-DD HH:mm")
        end_date = moment().startOf('hours').format("YYYY-MM-DD HH:mm")
    }
    //finally if we havent any date parameters
    //default start_date / end_date is for yesterday
    else {
        start_date = moment().subtract(1, 'days').startOf('day').format("YYYY-MM-DD HH:mm")
        end_date = moment().subtract(1, 'days').endOf('day').format("YYYY-MM-DD HH:mm")
    }
    persister.run(time_type, start_date, end_date, cb, conditions);
});

gulp.task('dbSync', function () {
    var sequelize = require('./src/models/index');
    sequelize.sequelize.sync();
});

gulp.task('fillNetworks', function () {
    var models = require('./src/models/');
    models.AdNetwork.fill();
});
gulp.task('fillAccounts', function () {
    var models = require('./src/models/');
    models.AdNetworkAccount.fill();
});
