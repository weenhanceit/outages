require "optparse"

namespace :demo do
  desc "Create a demonstration account"
  task create: [:destroy] do
    # puts "ARGC: #{ARGV.size} ARGV: #{ARGV}"
    # ARGV.shift(2)

    options = {}
    o = OptionParser.new
    o.banner = "Usage: rake demo:create -- [options]"
    o.on("-t DATETIME",
      "--demotime DATETIME",
      "The start time for the demonstration is DATETIME.",
      String) do |d|
      options[:demo_start_time] = d
    end
    o.on("-z ZONE",
      "--tz ZONE",
      "The demo will be given in the ZONE time zone.",
      String) do |tz|
      options[:time_zone] = tz
    end
    o.on("-p PASSWORD",
      "--password PASSWORD",
      "Use PASSWORD for all users.",
      String) do |password|
      options[:password] = password
    end

    args = o.order!(ARGV) {}
    # puts "ARGC: #{ARGV.size} ARGV: #{ARGV}"
    o.parse!

    # puts "OPTIONS: #{options.inspect}"
    puts "Creating..."

    Time.use_zone(options[:time_zone].present? ?
      Time.find_zone(options[:time_zone]) :
      Time.zone) do
      demo_start_time = if options[:demo_start_time].present?
                          Time.zone.parse(options[:demo_start_time])
                        else
                          Time.zone.now + 1.hour
                        end

      puts "Creating a demo to start at #{demo_start_time}"

      Account.transaction do
        account = Account.create!(name: "Outages Demonstration")

        user_params = {
          notification_periods_before_outage: 1,
          notification_period_interval: "days",
          notify_me_before_outage: true,
          notify_me_on_outage_changes: true,
          notify_me_on_note_changes: true,
          notify_me_on_outage_complete: true,
          notify_me_on_overdue_outage: true,
          preference_email_time: "8:00",
          preference_individual_email_notifications: false,
          preference_notify_me_by_email: false,
          privilege_account: false,
          privilege_edit_cis: false,
          privilege_edit_outages: false,
          privilege_manage_users: false,
          time_zone: options[:time_zone],
          password: options.fetch(:password, "password"),
          # encrypted_password: User.new.send(:password_digest, "password"),
          # reset_password_token:,
          # reset_password_sent_at:,
          # remember_created_at:,
          sign_in_count: 0,
          # current_sign_in_at:,
          # last_sign_in_at:,
          # current_sign_in_ip:,
          # last_sign_in_ip:,
          # confirmation_token:,
          confirmed_at: Time.zone.now - 1.hour,
          confirmation_sent_at: Time.zone.now - 2.hours,
          # unconfirmed_email:,
          failed_attempts: 0,
          # unlock_token:,
          # locked_at:
        }

        sales_agent = account.users.create!({
          name: "Sales Agent",
          email: "sales_agent@example.com",
          notify_me_on_note_changes: false,
          notify_me_on_overdue_outage: false
        }.reverse_merge(user_params))

        sales_app_support = account.users.create!({
          name: "Sales App Support",
          email: "sales_app_support@example.com",
          privilege_edit_cis: true,
          privilege_edit_outages: true
        }.reverse_merge(user_params))

        server_admin = account.users.create!({
          name: "Server Admin",
          email: "server_admin@example.com",
          privilege_edit_cis: true,
          privilege_edit_outages: true
        }.reverse_merge(user_params))

        email_notifications = account.users.create!({
          name: "Email Notifications",
          email: "email_notifications@example.com",
          preference_individual_email_notifications: true,
          preference_notify_me_by_email: true
        }.reverse_merge(user_params))

        # The shared database server
        db_server = account.cis.create!(
          name: "DB Server",
          description: "Honkin' big DB server."
        )

        # A bunch of servers.
        sales_prd_cluster = account.cis.create!(name: "Sales App Prod Cluster",
                                                description: "The production Sales supporting hardware.")
        1.upto(3).map do |i|
          account.cis.create!(name: "sal00#{i}prd",
                              description: "VM for Sales production application.")
        end.map do |ci|
          server_admin.watches.create!(watched: ci)
          db_server.parent_links.create!(parent: ci)
          sales_prd_cluster.child_links.create!(child: ci)
        end

        sales_prf_cluster = account.cis.create!(name: "Sales App Perf Cluster",
                                                description: "The performance test Sales suporting hardware.")
        1.upto(3).map do |i|
          account.cis.create!(name: "sal00#{i}prf",
                              description: "VM for Sales performance test application.")
        end.map do |ci|
          server_admin.watches.create!(watched: ci)
          db_server.parent_links.create!(parent: ci)
          sales_prf_cluster.child_links.create!(child: ci)
        end

        prd_web_cluster = account.cis.create!(name: "Web Prod",
                                              description: "The production web platform.")
        1.upto(2).map do |i|
          account.cis.create!(name: "web00#{i}prd",
                              description: "VM for production web platform.")
        end.map do |ci|
          server_admin.watches.create!(watched: ci)
          prd_web_cluster.child_links.create!(child: ci)
        end

        # Load balancers for the clusters.
        prd_load_balancer = account.cis.create!(name: "LB Prod",
                                                description: "Production load balancer.")
        [sales_prd_cluster, prd_web_cluster].each do |cluster|
          prd_load_balancer.child_links.create!(child: cluster)
        end

        prf_load_balancer = account.cis.create!(name: "LB Test",
                                                description: "Test load balancer.")
        prf_load_balancer.child_links.create!(child: sales_prf_cluster)

        # Create some applications
        sales_app_prd = account.cis.create!(name: "Sales Application Prod",
                                            description: "The production Sales application.")
        sales_app_prd.child_links.create!(child: sales_prd_cluster)

        sales_app_prf = account.cis.create!(name: "Sales Application Perf",
                                            description: "The performance testing Sales application.")
        sales_app_prf.child_links.create!(child: sales_prf_cluster)

        hr_app_prd = account.cis.create!(name: "H/R Application Prod",
                                         description: "The production H/R application. " \
          "The cluster is for load, not redundancy. " \
          "If any server is down, the application is down.")
        hr_app_prd.child_links.create!(child: prd_web_cluster)
        db_server.parent_links.create(parent: hr_app_prd)

        public_web_site = account.cis.create!(name: "Web Site",
                                              description: "The production public-facing web site. " \
          "All these applications are stateless web apps, " \
          "so they can run even if a server is taken down.")
        public_web_site.child_links.create!(child: prd_web_cluster)
        db_server.parent_links.create!(parent: public_web_site)

        # Some outages
        outage_params = {
          causes_loss_of_service: true,
          completed: false
        }
        web_outage_start = demo_start_time + 10.minutes
        web_outage = account.outages.create!({
          name: "Web Outage",
          description: "Update nginx and configure TLS for all connections.",
          start_time: web_outage_start,
          end_time: web_outage_start + 30.minutes
        }.reverse_merge(outage_params))
        web_outage.cis_outages.create!(ci: Ci.find_by(name: "web001prd"))

        test_lb_outage_start = demo_start_time + 15.minutes
        test_lb_outage = account.outages.create!({
          name: "LB Outage",
          description: "Deploy new load balancer config " \
                      "for testing.",
          start_time: test_lb_outage_start,
          end_time: test_lb_outage_start + 1.hour
        }.reverse_merge(outage_params))
        test_lb_outage.cis_outages.create!(ci: prf_load_balancer)

        db_outage_start = demo_start_time - 1.hour
        db_outage = account.outages.create!({
          name: "DB Outage",
          description: "Deploy new version of RDBMS.",
          start_time: db_outage_start,
          end_time: db_outage_start + 1.hour + 12.minutes
        }.reverse_merge(outage_params))
        db_outage.cis_outages.create!(ci: db_server)

        code_deploy_start = demo_start_time - 23.hours
        code_deploy = account.outages.create!({
          name: "Code deploy",
          description: "Code deploy of performance tweaks from main branch.",
          start_time: code_deploy_start,
          end_time: code_deploy_start + 30.minutes,
          completed: true
        }.reverse_merge(outage_params))
        code_deploy.cis_outages.create!(ci: Ci.find_by(name: "sal001prf"))
        code_deploy.cis_outages.create!(ci: Ci.find_by(name: "sal002prf"))
        code_deploy.cis_outages.create!(ci: Ci.find_by(name: "sal003prf"))

        load_balancer_config_start = demo_start_time + 23.hours
        load_balancer_config = account.outages.create!({
          name: "Load balancer config",
          description: "Deploy new production load balancer config " \
                      "in preparation for new system.",
          start_time: load_balancer_config_start,
          end_time: load_balancer_config_start + 30.minutes
        }.reverse_merge(outage_params))
        load_balancer_config.cis_outages.create!(ci: prd_load_balancer)

        db_outage_2_start = demo_start_time + 2.days - 1.hour
        db_outage_2 = account.outages.create!({
          name: "DB Outage",
          description: "Full cold backup of all data in preparation for " \
            "data centre relocation.",
          start_time: db_outage_2_start,
          end_time: db_outage_2_start + 5.hours
        }.reverse_merge(outage_params))
        db_outage_2.cis_outages.create!(ci: db_server)

        packet_size_start = demo_start_time + 29.hours
        packet_size = account.outages.create!({
          name: "IP packet size",
          description: "Configuration change of IP packet size on server.",
          start_time: packet_size_start,
          end_time: packet_size_start + 75.minutes
        }.reverse_merge(outage_params))
        packet_size.cis_outages.create!(ci: Ci.find_by(name: "sal001prf"))
        packet_size.cis_outages.create!(ci: Ci.find_by(name: "sal002prf"))
        packet_size.cis_outages.create!(ci: Ci.find_by(name: "sal003prf"))

        # Watches
        # Server admin watches are created above when the servers are created
        sales_agent.watches.create!([
                                      {
                                        watched: sales_app_prd
                                      },
                                      {
                                        watched: public_web_site
                                      }])
        sales_app_support.watches.create!(watched: sales_app_prd)
        email_notifications.watches.create!(watched: sales_app_prd)

        # Put out some helpful messages at the end.
        account.users.each do |u|
          puts "Created user: #{u.name} with e-mail: #{u.email}"
        end
      end
    end
  end

  desc "Destroy a demonstration account"
  task destroy: :environment do
    puts "Destroying..."
    account = Account.find_by(name: "Outages Demonstration")
    if account
      account.transaction do
        Outage.where(account: account).unscope(where: :active).destroy_all
        Ci.where(account: account).unscope(where: :active).destroy_all
        User.where(account: account).unscope(where: :active).destroy_all
        account.destroy
      end
    end
  end
end
