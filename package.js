Package.describe({
    name: 'steedos:portal',
    version: '0.0.2',
    summary: 'Steedos Portal',
    git: ''
});

Npm.depends({
  cookies: "0.6.1",
});

Package.onUse(function(api) { 
    api.versionsFrom("1.2.1");

    api.use('reactive-var');
    api.use('reactive-dict');
    api.use('coffeescript');
    api.use('random');
    api.use('ddp');
    api.use('check');
    api.use('ddp-rate-limiter');
    api.use('underscore');
    api.use('tracker');
    api.use('session');
    api.use('blaze');
    api.use('templating');
    api.use('webapp', 'server');
    
    api.use('flemay:less-autoprefixer@1.2.0');
    api.use('simple:json-routes@2.1.0');
    api.use('nimble:restivus@0.8.7');
    api.use('aldeed:simple-schema@1.3.3');
    api.use('aldeed:collection2@2.5.0');
    api.use('aldeed:tabular@1.6.0');
    api.use('aldeed:autoform@5.8.0');
    api.use('matb33:collection-hooks@0.8.1');
    api.use('cfs:standard-packages@0.5.9');
    api.use('iyyang:cfs-aliyun')
    api.use('cfs:s3');
    api.use('kadira:blaze-layout@2.3.0');
    api.use('kadira:flow-router@2.10.1');

    api.use('meteorhacks:ssr@2.2.0');
    api.use('steedos:lib@0.0.1');
    api.use('tap:i18n@1.7.0');
    api.use('meteorhacks:subs-manager');

    api.use('iyyang:cfs-aliyun@0.1.0');
    api.use('cfs:s3@0.1.3');

    api.use('steedos:emailjs');



    //api.add_files("package-tap.i18n", ["client", "server"]);
    tapi18nFiles = ['i18n/en.i18n.json', 'i18n/zh-CN.i18n.json']
    api.addFiles(tapi18nFiles, ['client', 'server']);

    api.addFiles('lib/core.coffee');
    api.addFiles('lib/modals/dashboards.coffee');
    api.addFiles('lib/modals/auths.coffee');
    api.addFiles('lib/modals/auth_users.coffee');
    api.addFiles('lib/admin.coffee');

    api.addFiles('client/views/_helpers.coffee', 'client');
    api.addFiles('client/views/portal_home.html', 'client');
    api.addFiles('client/views/portal_home.coffee', 'client');
    api.addFiles('client/views/portal_home.less', 'client');

    api.addFiles('client/router.coffee', 'client');
    api.addFiles('client/subscribe.coffee', 'client');


    api.addFiles('server/publications/portal_dashboards.coffee', 'server');
    api.addFiles('server/publications/auths.coffee', 'server');
    api.addFiles('server/publications/auth_users.coffee', 'server');

    api.addFiles('server/routes/app_sso.coffee', 'server');

    api.addAssets("client/jquery/jquery-1.11.2.min.js", "client");

    // EXPORT
    api.export('Portal');


    
});

Package.onTest(function(api) {

});
