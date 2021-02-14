# -*- encoding : utf-8 -*-

class AssetsController < ApplicationController
    def favicon
        send_file 'public/favicon.ico', :type => 'image/vnd.microsoft.icon', :disposition => 'inline'
    end

    def robots
        send_file 'public/robots.txt', :type => 'text/plain', :disposition => 'inline'
    end
end