module TestSuite
  def ci_list
    [
      {
      "name" =>"devenv01",
      "description" => "Ubuntu 16.04 for Development Group."
    },
    {
    "name" =>"devenv02",
    "description" => "Ubuntu 16.04 for Test Group."
  },
      {
      "name" =>"afappubu0020",
      "description" => "Ubuntu 16.04 server for Autism Funding application."
    },
      {
      "name" =>"afappubu0021",
      "description" => "Ubuntu 16.04 server for Autism Funding application."
    },
      {
      "name" =>"afappubu0022",
      "description" => "Ubuntu 16.04 server for Autism Funding application."
    },
      {
      "name" =>"afappubu0023",
      "description" => "Ubuntu 16.04 server for Autism Funding application."
    },
      {
      "name" =>"afappubu0024",
      "description" => "Ubuntu 16.04 server for Autism Funding application."
    }
    ]
  end
  def note_list
    [
      {
        "note_date"=>"2017-04-23",
        "user" => "Larry",
        "note" => "This is a note to say that this is getting too complicated and time consuming!"
      },
      {
        "note_date"=>"2017-04-25",
        "user" => "Phil",
        "note" => "I couldn't agree more"
      }
    ]
  end
  def outage_list
    cis = ci_list
    notes = note_list
    [
      {"short_description" => "Upgrade of Autism-Funding Servers",
        "long_description" => "This outage is really scary because it impacts a bunch of things",
        "start_time" => (Time.now + 7.days),
        "end_time" => (Time.now + 7.days + 2.hours),
        "completed" => "no",
        "status" => "",
        "cis" => [{"id"=>2, "ci"=>cis[2]}],
        "notes" => []
      },
      {"short_description" => "Upgrade of Autism-Funding Servers",
        "long_description" => "This outage is really scary because it impacts a bunch of things",
        "start_time" => (Time.now + 7.days),
        "end_time" => (Time.now + 7.days + 2.hours),
        "completed" => "no",
        "status" => "",
        "cis" => [{"id"=>2, "ci"=>cis[2]}],
        "notes" => []
      },
      {"short_description" => "Development Systems Maintenance",
        "long_description" => "A really long description that nobody will read",
        "start_time" => (Time.now + 5.days),
        "end_time" => (Time.now + 5.days + 2.hours),
        "completed" => "no",
        "status" => "free form note",
        "cis" => [{"id"=>0, "ci"=>cis[0]},{"id"=>1, "ci"=>cis[1]}],
        "notes" => []
      },
      {"short_description" => "Upgrade of Autism-Funding Servers",
        "long_description" => "This outage is really scary because it impacts a bunch of things",
        "start_time" => (Time.now + 7.days),
        "end_time" => (Time.now + 7.days + 2.hours),
        "completed" => "no",
        "status" => "",
        "cis" => [{"id"=>2, "ci"=>cis[2]},{"id"=>3, "ci"=>cis[3]},{"id"=>4, "ci"=>cis[4]},{"id"=>5, "ci"=>cis[5]}],
        "notes" => [{"id"=>0, "note_item"=>notes[0]},{"id"=>1, "note_item"=>notes[1]}]
      }
    ]
  end

end
