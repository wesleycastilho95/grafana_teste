FROM grafana/grafana:7.2.0

COPY grafana.ini /etc/grafana/grafana.ini
COPY icon-logo.svg /usr/share/grafana/public/img/grafana_icon.svg
COPY fav32.png /usr/share/grafana/public/img/fav32.png
COPY /provisioning_dashboards/* /etc/grafana/provisioning/dashboards/
COPY /datasources/* /etc/grafana/provisioning/datasources/
COPY /dashboards/* /var/lib/grafana/dashboards/

USER root

ARG GF_INSTALL_IMAGE_RENDERER_PLUGIN="true"

ENV GF_PATHS_PLUGINS="/var/lib/grafana-plugins"

RUN mkdir -p "$GF_PATHS_PLUGINS" && \
    chown -R grafana:grafana "$GF_PATHS_PLUGINS"

RUN if [ $GF_INSTALL_IMAGE_RENDERER_PLUGIN = "true" ]; then \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk --no-cache  upgrade && \
    apk add --no-cache udev ttf-opensans chromium && \
    rm -rf /tmp/* && \
    rm -rf /usr/share/grafana/tools/phantomjs; \
fi

USER grafana

ENV GF_RENDERER_PLUGIN_CHROME_BIN="/usr/bin/chromium-browser"

RUN if [ $GF_INSTALL_IMAGE_RENDERER_PLUGIN = "true" ]; then \
    grafana-cli \
        --pluginsDir "$GF_PATHS_PLUGINS" \
        --pluginUrl https://github.com/grafana/grafana-image-renderer/releases/latest/download/plugin-linux-x64-glibc-no-chromium.zip \
        plugins install grafana-image-renderer; \
fi

ARG GF_INSTALL_PLUGINS="alexanderzobnin-zabbix-app,agenty-flowcharting-panel,aidanmountford-html-panel,alexandra-trackmap-panel,bessler-pictureit-panel,blackmirror1-singlestat-math-panel,blackmirror1-statusbygroup-panel,briangann-datatable-panel,briangann-gauge-panel,btplc-alarm-box-panel,btplc-peak-report-panel,btplc-status-dot-panel,btplc-trend-box-panel,citilogics-geoloop-panel,corpglory-progresslist-panel,digiapulssi-breadcrumb-panel,digiapulssi-organisations-panel,digrich-bubblechart-panel,farski-blendstat-panel,fatcloud-windrose-panel,flant-statusmap-panel,grafana-clock-panel,grafana-piechart-panel,grafana-polystat-panel,grafana-worldmap-panel,gretamosa-topology-panel,jdbranham-diagram-panel,jeanbaptistewatenberg-percent-panel,larona-epict-panel,macropower-analytics-panel,marcuscalidus-svg-panel,michaeldmoore-annunciator-panel,michaeldmoore-multistat-panel,mtanda-heatmap-epoch-panel,mtanda-histogram-panel,mxswat-separator-panel,natel-discrete-panel,natel-influx-admin-panel,natel-plotly-panel,neocat-cal-heatmap-panel,novalabs-annotations-panel,petrslavotinek-carpetplot-panel,pierosavi-imageit-panel,pr0ps-trackmap-panel,ryantxu-ajax-panel,ryantxu-annolist-panel,satellogic-3d-globe-panel,savantly-heatmap-panel,scadavis-synoptic-panel,smartmakers-trafficlight-panel,snuids-radar-panel,snuids-trafficlights-panel,vonage-status-panel,yesoreyeram-boomtable-panel,yesoreyeram-boomtheme-panel,zuburqan-parity-report-panel,grafana-worldmap-panel"

RUN if [ ! -z "${GF_INSTALL_PLUGINS}" ]; then \
    OLDIFS=$IFS; \
        IFS=','; \
    for plugin in ${GF_INSTALL_PLUGINS}; do \
        IFS=$OLDIFS; \
        grafana-cli --pluginsDir "$GF_PATHS_PLUGINS" plugins install ${plugin}; \
    done; \
fi