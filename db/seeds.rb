# Core records required by the application in every environment.
%w[registered contestant alumni speaker teacher admin].each do |role|
  Role.find_or_create_by!(name: role)
end

%w[web utilitar educational multimedia roboti].each do |category|
  Category.find_or_create_by!(name: category)
end

current_edition = Edition.find_or_initialize_by(
  name: "InfoEducație Demo 2026"
)
current_edition.assign_attributes(
  year: 2026,
  camp_start_date: Date.new(2026, 7, 20),
  camp_end_date: Date.new(2026, 7, 24),
  motto: "Construim idei, testăm viitorul",
  registration_start_date: DateTime.new(2026, 6, 1, 0, 0, 0),
  registration_end_date: DateTime.new(2026, 6, 30, 0, 0, 0),
  travel_data_deadline: nil,
  published: true,
  current: true,
  show_results: true,
  projects_forum_category: "demo-2026-projects",
  talks_forum_category: "demo-2026-talks"
)
current_edition.save!

admin_email = ENV.fetch("ADMIN_EMAIL", "admin@example.test")
admin_password = ENV["ADMIN_PASSWORD"]

if admin_password.present? && !User.exists?(email: admin_email)
  user = User.new(
    email: admin_email,
    password: admin_password,
    password_confirmation: admin_password,
    first_name: "Demo",
    last_name: "Administrator"
  )
  user.skip_confirmation!
  user.save!
  user.roles << Role.find_by!(name: "admin")
end

# This entirely fictional dataset gives local UI development realistic content
# without copying production or personal data. Names, schools, projects,
# results, biographies, URLs and all private registration fields are invented.
seed_demo_data = ActiveModel::Type::Boolean.new.cast(
  ENV.fetch("SEED_DEMO_DATA", Rails.env.development?)
)

if seed_demo_data
  demo_password = ENV.fetch("DEMO_USER_PASSWORD", "local-infoedu-demo-2026")

  seed_user = lambda do |email:, first_name:, last_name:, job: nil|
    user = User.find_or_initialize_by(email: email)
    user.assign_attributes(first_name: first_name, last_name: last_name, job: job)

    if user.new_record?
      user.password = demo_password
      user.password_confirmation = demo_password
      user.skip_confirmation!
    end

    user.save!
    user
  end

  contestant_role = Role.find_by!(name: "contestant")
  alumni_role = Role.find_by!(name: "alumni")

  participant_data = [
    {
      key: :budget_quest,
      first_name: "Mara",
      last_name: "Demo",
      school_name: "Liceul Demonstrativ Nord",
      county: "Județ Demo Nord",
      city: "Oraș Demo",
      mentor_first_name: "Elena",
      mentor_last_name: "Mentor"
    },
    {
      key: :parallel_dreams,
      first_name: "Tudor",
      last_name: "Exemplu",
      school_name: "Colegiul Exemplu",
      county: "Județ Exemplu",
      city: "Exempluville",
      mentor_first_name: "Dan",
      mentor_last_name: "Profesor"
    },
    {
      key: :flexibot_ada,
      first_name: "Ada",
      last_name: "Fictivă",
      school_name: "Liceul Tehnologic Fictiv",
      county: "Județ Demo Est",
      city: "Municipiul Fictiv",
      mentor_first_name: "Mira",
      mentor_last_name: "Exemplu"
    },
    {
      key: :flexibot_radu,
      first_name: "Radu",
      last_name: "Mostră",
      school_name: "Liceul Tehnologic Fictiv",
      county: "Județ Demo Est",
      city: "Municipiul Fictiv",
      mentor_first_name: "Mira",
      mentor_last_name: "Exemplu"
    },
    {
      key: :pixel_vault,
      first_name: "Ioana",
      last_name: "Simulare",
      school_name: "Colegiul Local de Informatică",
      county: "Județ Local",
      city: "Oraș Local",
      mentor_first_name: "Teo",
      mentor_last_name: "Ghid"
    },
    {
      key: :code_garden_victor,
      first_name: "Victor",
      last_name: "Local",
      school_name: "Academia Demo Digital",
      county: "Județ Test",
      city: "Testopolis",
      mentor_first_name: "Ana",
      mentor_last_name: "Demo"
    },
    {
      key: :code_garden_sonia,
      first_name: "Sonia",
      last_name: "Test",
      school_name: "Academia Demo Digital",
      county: "Județ Test",
      city: "Testopolis",
      mentor_first_name: "Radu",
      mentor_last_name: "Îndrumător"
    }
  ]

  participant_groups = [
    {
      members: [[:eco_atlas_daria, "Daria", "Demo"], [:eco_atlas_luca, "Luca", "Verde"]],
      school_name: "Colegiul Verde Demonstrativ",
      county: "Judet Demo Sud",
      city: "Verdegrad",
      mentor_first_name: "Irina",
      mentor_last_name: "Ghid"
    },
    {
      members: [[:logic_lab, "Andrei", "Logic"]],
      school_name: "Liceul Fictiv Central",
      county: "Judet Mostra",
      city: "Mostreni",
      mentor_first_name: "Sorin",
      mentor_last_name: "Model"
    },
    {
      members: [[:soundscapes_ilinca, "Ilinca", "Cadru"], [:soundscapes_matei, "Matei", "Pixel"]],
      school_name: "Liceul Creativ Demo",
      county: "Judet Scena",
      city: "Cadropolis",
      mentor_first_name: "Oana",
      mentor_last_name: "Studio"
    },
    {
      members: [[:paper_shadow, "Eva", "Scena"]],
      school_name: "Academia Vizuala Exemplu",
      county: "Judet Lumina",
      city: "Luminis",
      mentor_first_name: "Calin",
      mentor_last_name: "Regizor"
    },
    {
      members: [[:seed_rover_rares, "Rares", "Motor"], [:seed_rover_cora, "Cora", "Senzor"]],
      school_name: "Colegiul Tehnic Demo",
      county: "Judet Mecanic",
      city: "Rotoria",
      mentor_first_name: "Vlad",
      mentor_last_name: "Atelier"
    },
    {
      members: [[:aqua_sentinel, "Denis", "Circuit"]],
      school_name: "Liceul Experimental Local",
      county: "Judet Delta Demo",
      city: "Aquapolis",
      mentor_first_name: "Diana",
      mentor_last_name: "Prototip"
    },
    {
      members: [[:study_compass_bianca, "Bianca", "Plan"], [:study_compass_paul, "Paul", "Orar"]],
      school_name: "Colegiul Orizont Fictiv",
      county: "Judet Orizont",
      city: "Planesti",
      mentor_first_name: "Ioan",
      mentor_last_name: "Organizator"
    },
    {
      members: [[:safe_notes, "Miruna", "Cheie"]],
      school_name: "Liceul Digital Mostra",
      county: "Judet Cheie",
      city: "Criptograd",
      mentor_first_name: "Alina",
      mentor_last_name: "Model"
    },
    {
      members: [[:civic_pulse_daria, "Daria", "Retea"], [:civic_pulse_mihai, "Mihai", "Portal"]],
      school_name: "Academia Civica Demo",
      county: "Judet Agora",
      city: "Agora Noua",
      mentor_first_name: "Mihnea",
      mentor_last_name: "Web"
    },
    {
      members: [[:museum_mapper, "Lia", "Harta"]],
      school_name: "Colegiul Patrimoniu Exemplu",
      county: "Judet Muzeu",
      city: "Galeria",
      mentor_first_name: "Sabina",
      mentor_last_name: "Curator"
    }
  ]

  participant_groups.each do |group|
    group.fetch(:members).each do |key, first_name, last_name|
      participant_data << group.except(:members).merge(key:, first_name:, last_name:)
    end
  end

  contestants = participant_data.each_with_index.to_h do |data, index|
    user = seed_user.call(
      email: "participant-#{data[:key]}@example.test",
      first_name: data[:first_name],
      last_name: data[:last_name]
    )
    user.roles << contestant_role unless user.roles.include?(contestant_role)

    contestant = Contestant.find_or_initialize_by(
      user: user,
      edition: current_edition
    )
    contestant.assign_attributes(
      address: "Adresă locală de test #{index + 1}",
      city: data[:city],
      county: data[:county],
      country: "România",
      zip_code: "000000",
      sex: 3,
      cnp: "LOCAL-DEMO-#{index + 1}",
      id_card_type: "DEMO",
      id_card_number: "DEMO-2026-#{index + 1}",
      phone_number: "+40000000000",
      school_name: data[:school_name],
      grade: "XI",
      school_county: data[:county],
      school_city: data[:city],
      school_country: "România",
      date_of_birth: Date.new(2009, 1, index + 1),
      mentoring_teacher_first_name: data[:mentor_first_name],
      mentoring_teacher_last_name: data[:mentor_last_name],
      official: true,
      present_in_camp: true,
      paying_camp_accommodation: false
    )
    contestant.save!

    [data[:key], contestant]
  end

  project_data = [
    {
      title: "Budget Quest",
      category: "educational",
      contestant_keys: [:budget_quest],
      description: "Joc educațional fictiv despre administrarea unui buget lunar și luarea deciziilor financiare responsabile.",
      technical_description: "Aplicație demonstrativă Flutter cu stocare locală și lecții definite în fișiere JSON.",
      system_requirements: "Telefon Android demonstrativ sau emulator local.",
      source_url: "https://example.test/projects/budget-quest",
      homepage: nil,
      score: 72.5,
      extra_score: 18.0,
      prize: "I"
    },
    {
      title: "Parallel Dreams",
      category: "multimedia",
      contestant_keys: [:parallel_dreams],
      description: "Scurtmetraj fictiv despre două versiuni paralele ale aceluiași oraș imaginar.",
      technical_description: "Animație 2D și montaj demonstrativ realizate cu unelte grafice locale.",
      system_requirements: "Player video și sistem audio.",
      source_url: "https://example.test/projects/parallel-dreams",
      homepage: nil,
      score: 70.0,
      extra_score: 16.5,
      prize: "I"
    },
    {
      title: "FlexiBot",
      category: "roboti",
      contestant_keys: [:flexibot_ada, :flexibot_radu],
      description: "Braț robotic fictiv care sortează cuburi colorate într-un traseu demonstrativ.",
      technical_description: "Prototip demonstrativ cu microcontroler, senzori de culoare și servomotoare.",
      system_requirements: "Microcontroler generic, trei servomotoare și un banc local de test.",
      source_url: "https://example.test/projects/flexibot",
      homepage: nil,
      score: 75.0,
      extra_score: 14.25,
      prize: "I"
    },
    {
      title: "Pixel Vault",
      category: "utilitar",
      contestant_keys: [:pixel_vault],
      description: "Utilitar fictiv pentru organizarea, etichetarea și arhivarea colecțiilor de imagini.",
      technical_description: "Aplicație desktop demonstrativă cu index local și căutare după etichete.",
      system_requirements: "Calculator cu minimum 4 GB RAM și spațiu local pentru fișiere demo.",
      source_url: "https://example.test/projects/pixel-vault",
      homepage: nil,
      score: 73.25,
      extra_score: 19.75,
      prize: "I"
    },
    {
      title: "Code Garden",
      category: "web",
      contestant_keys: [:code_garden_victor, :code_garden_sonia],
      description: "Platformă web fictivă în care elevii învață programare cultivând o grădină virtuală.",
      technical_description: "Aplicație demonstrativă React cu API local și bază de date PostgreSQL.",
      system_requirements: "Browser modern și conexiune la serverul local de dezvoltare.",
      source_url: "https://example.test/projects/code-garden",
      homepage: "https://code-garden.example.test",
      score: 76.0,
      extra_score: 20.0,
      prize: "I"
    }
  ]

  additional_projects = [
    {
      title: "Eco Atlas",
      category: "educational",
      contestant_keys: [:eco_atlas_daria, :eco_atlas_luca],
      description: "Atlas educational fictiv cu misiuni despre ecosisteme si consum responsabil.",
      homepage: "https://eco-atlas.example.test",
      score: 69.5,
      extra_score: 17.0,
      prize: "II"
    },
    {
      title: "Logic Lab",
      category: "educational",
      contestant_keys: [:logic_lab],
      description: "Laborator fictiv de puzzle-uri care explica algoritmi prin experimente scurte.",
      score: 64.0,
      extra_score: 15.5,
      prize: "III"
    },
    {
      title: "Soundscapes",
      category: "multimedia",
      contestant_keys: [:soundscapes_ilinca, :soundscapes_matei],
      description: "Experienta multimedia fictiva despre sunetele unui oras imaginar pe durata unei zile.",
      homepage: "https://soundscapes.example.test",
      score: 67.75,
      extra_score: 18.0,
      prize: "II"
    },
    {
      title: "Paper Shadow",
      category: "multimedia",
      contestant_keys: [:paper_shadow],
      description: "Animatie fictiva din decoruri de hartie despre curaj si colaborare.",
      score: 62.5,
      extra_score: 14.0,
      prize: "III"
    },
    {
      title: "Seed Rover",
      category: "roboti",
      contestant_keys: [:seed_rover_rares, :seed_rover_cora],
      description: "Robot fictiv care monitorizeaza rasaduri si simuleaza udarea selectiva.",
      score: 71.25,
      extra_score: 15.0,
      prize: "II"
    },
    {
      title: "Aqua Sentinel",
      category: "roboti",
      contestant_keys: [:aqua_sentinel],
      description: "Prototip fictiv pentru observarea parametrilor apei intr-un bazin demonstrativ.",
      score: 65.5,
      extra_score: 13.5,
      prize: "III"
    },
    {
      title: "Study Compass",
      category: "utilitar",
      contestant_keys: [:study_compass_bianca, :study_compass_paul],
      description: "Organizator fictiv pentru teme, sesiuni de studiu si obiective saptamanale.",
      homepage: "https://study-compass.example.test",
      score: 68.0,
      extra_score: 16.25,
      prize: "II"
    },
    {
      title: "Safe Notes",
      category: "utilitar",
      contestant_keys: [:safe_notes],
      description: "Carnet fictiv pentru notite locale organizate si protejate cu o parola demonstrativa.",
      score: 63.75,
      extra_score: 14.5,
      prize: "III"
    },
    {
      title: "Civic Pulse",
      category: "web",
      contestant_keys: [:civic_pulse_daria, :civic_pulse_mihai],
      description: "Portal civic fictiv pentru propuneri locale, sondaje si urmarirea ideilor comunitatii.",
      homepage: "https://civic-pulse.example.test",
      score: 72.0,
      extra_score: 18.5,
      prize: "II"
    },
    {
      title: "Museum Mapper",
      category: "web",
      contestant_keys: [:museum_mapper],
      description: "Ghid web fictiv pentru explorarea exponatelor si construirea unor tururi tematice.",
      homepage: "https://museum-mapper.example.test",
      score: 66.25,
      extra_score: 15.75,
      prize: "III"
    }
  ]

  project_data.concat(additional_projects.map do |data|
    slug = data.fetch(:title).parameterize
    {
      technical_description: "Proiect demonstrativ pentru verificarea fluxurilor locale de participanti si rezultate.",
      system_requirements: "Browser modern sau mediu local de test.",
      source_url: "https://example.test/projects/#{slug}",
      homepage: nil
    }.merge(data)
  end)

  project_data.each do |data|
    project = Project.find_or_initialize_by(
      title: data[:title],
      edition: current_edition
    )
    project.assign_attributes(
      category: Category.find_by!(name: data[:category]),
      contestants: data[:contestant_keys].map { |key| contestants.fetch(key) },
      description: data[:description],
      technical_description: data[:technical_description],
      system_requirements: data[:system_requirements],
      source_url: data[:source_url],
      homepage: data[:homepage],
      open_source: true,
      finished: true,
      status: Project::STATUS_APPROVED,
      score: data[:score],
      extra_score: data[:extra_score],
      prize: data[:prize]
    )
    project.save!
  end

  news_articles = [
    {
      title: "Ediția demonstrativă 2026 este pregătită",
      pinned: true,
      body: <<~HTML
        <p><strong>Acesta este un articol fictiv folosit pentru dezvoltarea interfeței locale.</strong></p>
        <p>Motto demonstrativ: <em>Construim idei, testăm viitorul!</em></p>
        <p>Conținutul, datele și locurile din această bază de date sunt inventate.</p>
      HTML
    },
    {
      title: "Rezultatele demonstrative sunt disponibile",
      pinned: false,
      body: <<~HTML
        <p>Rezultatele fictive pentru ediția demonstrativă 2026 sunt acum vizibile în interfața locală.</p>
        <p>Toate numele, proiectele și punctajele afișate sunt date de test inventate.</p>
      HTML
    }
  ]

  news_articles.each do |data|
    article = News.find_or_initialize_by(
      title: data[:title],
      edition: current_edition
    )
    article.assign_attributes(body: data[:body], pinned: data[:pinned])
    article.save!
  end

  historical_edition_names = {
    2022 => "Ediția demonstrativă 2022",
    2024 => "Ediția demonstrativă 2024"
  }

  historical_editions = historical_edition_names.to_h do |year, name|
    edition = Edition.find_or_initialize_by(name: name)
    edition.assign_attributes(
      year: year,
      motto: "InfoEducație #{year}",
      registration_start_date: DateTime.new(year, 1, 1),
      registration_end_date: DateTime.new(year, 1, 2),
      projects_forum_category: "Lucrări #{year}",
      talks_forum_category: "Prezentări #{year}",
      published: false,
      current: false,
      show_results: false
    )
    edition.save!
    [year, edition]
  end

  alumni_data = [
    {
      email: "alumnus-alex-demo@example.test",
      first_name: "Alex",
      last_name: "Demo",
      edition_years: [2022, 2024],
      description: "Biografie fictivă: edițiile demonstrative m-au încurajat să experimentez, să colaborez și să îmi prezint ideile mai clar."
    },
    {
      email: "alumnus-mara-exemplu@example.test",
      first_name: "Mara",
      last_name: "Exemplu",
      edition_years: [2024],
      description: "Biografie fictivă: experiența demo mi-a arătat cât de mult contează feedbackul, lucrul în echipă și o prezentare bine repetată."
    }
  ]

  alumni_data.each do |data|
    user = seed_user.call(
      email: data[:email],
      first_name: data[:first_name],
      last_name: data[:last_name]
    )
    user.roles << alumni_role unless user.roles.include?(alumni_role)

    alumnus = Alumnus.find_or_initialize_by(user: user)
    alumnus.description = data[:description]
    alumnus.editions = data[:edition_years].map do |year|
      historical_editions.fetch(year)
    end
    alumnus.save!
  end
end
