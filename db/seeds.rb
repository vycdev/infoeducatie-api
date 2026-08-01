# Core records required by the application in every environment.
%w[registered contestant alumni speaker teacher admin].each do |role|
  Role.find_or_create_by!(name: role)
end

%w[web utilitar educational multimedia roboti].each do |category|
  Category.find_or_create_by!(name: category)
end

current_edition = Edition.find_or_initialize_by(
  name: "2026 Olimpiada Națională de Inovare și Creație digitală"
)
current_edition.assign_attributes(
  year: 2026,
  camp_start_date: Date.new(2026, 7, 28),
  camp_end_date: Date.new(2026, 7, 31),
  motto: "Noi construim meseriile viitorului",
  registration_start_date: DateTime.new(2026, 6, 25, 0, 0, 0),
  registration_end_date: DateTime.new(2026, 7, 22, 0, 0, 0),
  travel_data_deadline: nil,
  published: true,
  current: true,
  show_results: true,
  projects_forum_category: "77",
  talks_forum_category: "78"
)
current_edition.save!

admin_email = ENV.fetch("ADMIN_EMAIL", "admin@infoeducatie.ro")
admin_password = ENV["ADMIN_PASSWORD"]

if admin_password.present? && !User.exists?(email: admin_email)
  user = User.new(
    email: admin_email,
    password: admin_password,
    password_confirmation: admin_password,
    first_name: "Super",
    last_name: "Admin"
  )
  user.skip_confirmation!
  user.save!
  user.roles << Role.find_by!(name: "admin")
end

# The public-data snapshot below gives local UI development realistic content
# without copying private registration data. Public names, schools, results and
# biographies were captured from https://api.infoeducatie.ro/v1 on 2026-08-01.
# All email addresses, identity fields, addresses, phone numbers and birth dates
# are deliberately fake.
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
      key: :finedu,
      first_name: "Alexandru Radu",
      last_name: "Circiumaru",
      school_name: "Liceul Teoretic \"Alexandru Ioan Cuza\"",
      county: "București",
      city: "București",
      mentor_first_name: "Valentina",
      mentor_last_name: "Chirita"
    },
    {
      key: :dual_pulse,
      first_name: "Daria",
      last_name: "Laza",
      school_name: "Colegiul Național „Samuil Vulcan”",
      county: "Bihor",
      city: "Beiuș",
      mentor_first_name: "Claudia",
      mentor_last_name: "Buran"
    },
    {
      key: :neurogrip_matei,
      first_name: "Matei Petru",
      last_name: "Ruță",
      school_name: "Colegiul Național Grigore Moisil",
      county: "București",
      city: "București",
      mentor_first_name: "Mihaela",
      mentor_last_name: "Garabet"
    },
    {
      key: :neurogrip_razvan,
      first_name: "Răzvan",
      last_name: "Glaje",
      school_name: "Colegiul Național Grigore Moisil",
      county: "București",
      city: "București",
      mentor_first_name: "Mihaela",
      mentor_last_name: "Garabet"
    },
    {
      key: :scam,
      first_name: "Ilie",
      last_name: "Demian",
      school_name: "Colegiul Național „Emanuil Gojdu”",
      county: "Bihor",
      city: "Oradea",
      mentor_first_name: "Tanța",
      mentor_last_name: "Hodișan"
    },
    {
      key: :synaro_cristi,
      first_name: "Cristi",
      last_name: "Stiegelbauer",
      school_name: "Liceul Teoretic \"Grigore Moisil\"",
      county: "Timiș",
      city: "Timișoara",
      mentor_first_name: "Luminita",
      mentor_last_name: "Keresztes"
    },
    {
      key: :synaro_mihai,
      first_name: "Mihai",
      last_name: "Gorunescu",
      school_name: "Liceul Teoretic \"Grigore Moisil\"",
      county: "Timiș",
      city: "Timișoara",
      mentor_first_name: "Adriana",
      mentor_last_name: "Simulescu"
    }
  ]

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
      title: "FinEdu",
      category: "educational",
      contestant_keys: [:finedu],
      description: "Aplicație offline de educație financiară pentru adolescenți, cu lecții interactive, simulări și urmărirea cheltuielilor.",
      technical_description: "Aplicație Flutter/Dart cu SQLite, Riverpod, sincronizare opțională și o suită de teste automate.",
      system_requirements: "Telefon cu Android 6 sau mai nou; aplicația funcționează fără cont și fără conexiune la internet.",
      source_url: "https://github.com/Circiii/FinEdu.git",
      homepage: nil,
      score: 67.71,
      extra_score: 76.0,
      prize: "I"
    },
    {
      title: "Dual Pulse",
      category: "multimedia",
      contestant_keys: [:dual_pulse],
      description: "Proiect multimedia despre un tânăr care refuză să aleagă între două vocații: arta și medicina.",
      technical_description: "Ilustrație și animație 2D, modelare 3D, filmare și montaj realizate cu Ibis Paint X, FlipaClip, Nomad Sculpt și CapCut.",
      system_requirements: "Player video, conexiune la internet și sistem audio.",
      source_url: "https://www.youtube.com/watch?v=1v7-uDg38wk",
      homepage: nil,
      score: 67.75,
      extra_score: 62.63,
      prize: "I"
    },
    {
      title: "NeuroGrip",
      category: "roboti",
      contestant_keys: [:neurogrip_matei, :neurogrip_razvan],
      description: "Exoschelet robotic care folosește semnale EMG pentru asistarea și reabilitarea mișcărilor degetelor.",
      technical_description: "Sistem ESP32 cu achiziție EMG la 1 kHz, clasificare KNN, filtrare prin vot majoritar și control secvențial al servomotoarelor.",
      system_requirements: "ESP32, senzor EMG, cinci servomotoare MG90S, senzor ACS712 și Arduino IDE.",
      source_url: "https://github.com/RTZM09/EMG-asisted-eXoscheleton",
      homepage: nil,
      score: 81.43,
      extra_score: 33.43,
      prize: "I"
    },
    {
      title: "S.C.A.M.",
      category: "utilitar",
      contestant_keys: [:scam],
      description: "Emulator NES de mare acuratețe, scris integral în Rust și disponibil inclusiv în browser.",
      technical_description: "Emulator performant în Rust, compilat pentru web, cu implementarea componentelor hardware și a mapperelor NES.",
      system_requirements: "Calculator fabricat în ultimii 15 ani și conexiune la internet pentru versiunea web.",
      source_url: "https://github.com/insertokname/SCAM",
      homepage: nil,
      score: 86.25,
      extra_score: 84.75,
      prize: "I"
    },
    {
      title: "Synaro",
      category: "web",
      contestant_keys: [:synaro_cristi, :synaro_mihai],
      description: "Platformă web pentru dezvoltatori care transformă idei în proiecte rulabile și oferă workspaces izolate și agenți de automatizare.",
      technical_description: "Next.js, Fastify, PostgreSQL și Docker, cu SDK TypeScript, API public, integrare MCP și teste automate.",
      system_requirements: "Browser modern și conexiune la internet; pentru dezvoltare sunt necesare Node.js 20 și Docker.",
      source_url: "https://github.com/mihai888nextlab/synaro",
      homepage: "https://synaro.tech",
      score: 78.13,
      extra_score: 77.03,
      prize: "I"
    }
  ]

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
      title: "Avem ediția 2026",
      pinned: true,
      body: <<~HTML
        <p><strong>Ești interesat de creație digitală? Pregătește-te pentru Olimpiadă!</strong></p>
        <p>Motto: <em>Noi construim meseriile viitorului!</em></p>
        <p>Etapa națională are loc la Focșani, în perioada 28–31 iulie 2026.</p>
      HTML
    },
    {
      title: "Rezultatele ediției 2026 sunt disponibile",
      pinned: false,
      body: <<~HTML
        <p>Rezultatele Olimpiadei Naționale de Inovare și Creație digitală 2026 au fost publicate.</p>
        <p>Felicitări tuturor celor 211 participanți și echipelor celor 133 de proiecte înscrise!</p>
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
    2000 => "2000 Națională",
    2002 => "2002 Națională",
    2003 => "2003 Națională",
    2004 => "2004 Națională",
    2007 => "2007 Națională",
    2008 => "2008 Națională"
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
      email: "alumnus-cristian-strat@example.test",
      first_name: "Cristian",
      last_name: "Strat",
      edition_years: [2000, 2002, 2003, 2004],
      description: "InfoEducație mi-a oferit motivația să învăț tehnologii web și să dezvolt infoarena. Prezentarea este la fel de importantă ca lucrarea în sine: repetați înainte să veniți în fața comisiei."
    },
    {
      email: "alumnus-valentin-bora@example.test",
      first_name: "Valentin",
      last_name: "Bora",
      edition_years: [2007, 2008],
      description: "InfoEducație a fost un mediu în care, deși era concurs, lumea încerca să te ajute. Înveți într-o săptămână mai mult decât ți-ai putea imagina și îți dezvolți inclusiv abilitățile de prezentare."
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
