# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class SchoolMetadata
      MAPPING = {
        # Test school code passed for the test authorizer by MPASSid
        # "00000" => { name: "Testikoulu" },

        # Actual schools
        "00004" => { name: "Alppilan lukio" },
        "00026" => { name: "Brändö gymnasium" },
        "00081" => { name: "Helsingin luonnontiedelukio" },
        "00082" => { name: "Ressun lukio" },
        "00083" => { name: "Helsingin normaalilyseo" },
        "00084" => { name: "Helsingin ranskalais-suomalainen koulu" },
        "00085" => { name: "Helsingin saksalainen koulu" },
        "00087" => { name: "Suomalais-venäläinen koulu" },
        "00088" => { name: "Helsingin kuvataidelukio" },
        "00089" => { name: "Sibelius-lukio" },
        "00255" => { name: "Kallion lukio" },
        "00316" => { name: "Eiran aikuislukio" },
        "00394" => { name: "Englantilainen koulu" },
        "00518" => { name: "Mäkelänrinteen lukio" },
        "00539" => { name: "Töölön yhteiskoulun aikuislukio" },
        "00551" => { name: "Helsingin aikuislukio" },
        "00561" => { name: "Gymnasiet Lärkan" },
        "00607" => { name: "Tölö gymnasium" },
        "00648" => { name: "Helsingin medialukio" },
        "00670" => { name: "Helsingin kielilukio" },
        "00729" => { name: "Helsingin Rudolf Steiner -koulu" },
        "00842" => { name: "HY Viikin normaalikoulu" },
        "00845" => { name: "Etu-Töölön lukio" },
        "00915" => { name: "Vuosaaren lukio" },
        "01164" => { name: "H:gin Maalariammattikoulu" },
        "01294" => { name: "Suomen Diakoniaopisto" },
        "01428" => { name: "Jollas-opisto Oy" },
        "02558" => { name: "Suomen kansallisoopperan ja -baletin balettioppilaitos" },
        "03002" => { name: "Aleksis Kiven peruskoulu" },
        "03004" => { name: "Haagan peruskoulu" },
        "03005" => { name: "Hertsikan ala-aste" },
        "03010" => { name: "Kaisaniemen ala-asteen koulu" },
        "03011" => { name: "Kallion ala-asteen koulu" },
        "03013" => { name: "Katajanokan ala-asteen koulu" },
        "03014" => { name: "Konalan ala-asteen koulu" },
        "03015" => { name: "Kontulan ala-asteen koulu" },
        "03016" => { name: "Kulosaaren ala-asteen koulu" },
        "03020" => { name: "Maunulan ala-asteen koulu" },
        "03021" => { name: "Meilahden ala-asteen koulu" },
        "03022" => { name: "Mellunmäen ala-asteen koulu" },
        "03023" => { name: "Metsolan ala-asteen koulu" },
        "03024" => { name: "Munkkiniemen ala-asteen koulu" },
        "03025" => { name: "Munkkivuoren ala-asteen koulu" },
        "03026" => { name: "Lauttasaaren ala-asteen koulu" },
        "03030" => { name: "Oulunkylän ala-asteen koulu" },
        "03032" => { name: "Pakilan ala-asteen koulu" },
        "03033" => { name: "Pihlajamäen ala-asteen koulu" },
        "03034" => { name: "Pitäjänmäen peruskoulu" },
        "03035" => { name: "Porolahden peruskoulu" },
        "03036" => { name: "Puistolanraitin ala-asteen koulu" },
        "03038" => { name: "Puotilan ala-asteen koulu" },
        "03039" => { name: "Itäkeskuksen peruskoulu" },
        "03040" => { name: "Roihuvuoren ala-asteen koulu" },
        "03041" => { name: "Santahaminan ala-asteen koulu" },
        "03043" => { name: "Snellmanin ala-asteen koulu" },
        "03044" => { name: "Suomenlinnan ala-asteen koulu" },
        "03045" => { name: "Tahvonlahden ala-aste" },
        "03046" => { name: "Taivallahden peruskoulu" },
        "03047" => { name: "Tapanilan ala-asteen koulu" },
        "03048" => { name: "Tehtaankadun ala-asteen koulu" },
        "03049" => { name: "Pohjois-Haagan ala-asteen koulu" },
        "03050" => { name: "Töölön ala-asteen koulu" },
        "03051" => { name: "Vallilan ala-asteen koulu" },
        "03053" => { name: "Vartiokylän ala-asteen koulu" },
        "03056" => { name: "Yhtenäiskoulu" },
        "03059" => { name: "Brändö lågstadieskola" },
        "03061" => { name: "Drumsö lågstadieskola" },
        "03064" => { name: "Kottby Lågstadieskola" },
        "03069" => { name: "Minervaskolan" },
        "03071" => { name: "Månsas lågstadieskola" },
        "03074" => { name: "Staffansby lågstadieskola" },
        "03079" => { name: "Pasilan peruskoulu" },
        "03080" => { name: "Kannelmäen peruskoulu" },
        "03082" => { name: "Käpylän peruskoulu" },
        "03083" => { name: "Kankarepuiston peruskoulu" },
        "03085" => { name: "Kruununhaan yläasteen koulu" },
        "03086" => { name: "Laajasalon peruskoulu" },
        "03087" => { name: "Suutarinkylän peruskoulu" },
        "03088" => { name: "Meilahden yläasteen koulu" },
        "03089" => { name: "Myllypuron peruskoulu" },
        "03091" => { name: "Pakilan yläasteen koulu" },
        "03092" => { name: "Hiidenkiven peruskoulu" },
        "03094" => { name: "Pukinmäenkaaren peruskoulu" },
        "03096" => { name: "Ressun peruskoulu" },
        "03098" => { name: "Puistopolun peruskoulu" },
        "03099" => { name: "Vartiokylän yläasteen koulu" },
        "03100" => { name: "Vesalan peruskoulu" },
        "03101" => { name: "Vuoniityn peruskoulu" },
        "03103" => { name: "Malmin peruskoulu" },
        "03104" => { name: "Botby grundskola" },
        "03105" => { name: "Grundskolan Norsen" },
        "03106" => { name: "Hoplaxskolan" },
        "03108" => { name: "Åshöjdens grundskola" },
        "03111" => { name: "Karviaistien koulu" },
        "03112" => { name: "Toivolan koulu" },
        "03113" => { name: "Lemmilän koulu" },
        "03114" => { name: "Naulakallion koulu" },
        "03116" => { name: "Helsingin Juutalainen Yhteiskoulu" },
        "03251" => { name: "Keinutien ala-asteen koulu" },
        "03252" => { name: "Pihlajiston ala-asteen koulu" },
        "03279" => { name: "Sophie Mannerheimin koulu" },
        "03289" => { name: "Malminkartanon ala-asteen koulu" },
        "03295" => { name: "Maatullin ala-asteen koulu" },
        "03311" => { name: "Suutarilan ala-asteen koulu" },
        "03340" => { name: "Zacharias Topeliusskolan" },
        "03391" => { name: "Apollon yhteiskoulu" },
        "03393" => { name: "Helsingin Suomalainen Yhteiskoulu" },
        "03394" => { name: "Helsingin Uusi yhteiskoulu" },
        "03395" => { name: "Helsingin yhteislyseo" },
        "03396" => { name: "Herttoniemen yhteiskoulu" },
        "03398" => { name: "Kulosaaren yhteiskoulu" },
        "03400" => { name: "Lauttasaaren yhteiskoulu" },
        "03401" => { name: "Maunulan yhteiskoulu - Helsingin matematiikkalukio" },
        "03402" => { name: "Munkkiniemen yhteiskoulu" },
        "03404" => { name: "Oulunkylän yhteiskoulu" },
        "03405" => { name: "Pohjois-Haagan yhteiskoulu" },
        "03408" => { name: "Töölön yhteiskoulu" },
        "03410" => { name: "Marjatta-koulu" },
        "03417" => { name: "Solakallion koulu" },
        "03419" => { name: "Paloheinän ala-asteen koulu" },
        "03479" => { name: "Siltamäen ala-asteen koulu" },
        "03480" => { name: "Koskelan ala-asteen koulu" },
        "03510" => { name: "International School of Helsinki" },
        "03533" => { name: "Pihkapuiston ala-asteen koulu" },
        "03540" => { name: "Elias-koulu" },
        "03577" => { name: "Puistolan peruskoulu" },
        "03579" => { name: "Laakavuoren ala-aste" },
        "03605" => { name: "Hietakummun ala-asteen koulu" },
        "03607" => { name: "Degerö lågstadieskola" },
        "03614" => { name: "Merilahden peruskoulu" },
        "03638" => { name: "Helsingin Kristillinen koulu" },
        "03662" => { name: "Ruoholahden ala-asteen koulu" },
        "03664" => { name: "Herttoniemenrannan ala-asteen koulu" },
        "03672" => { name: "Pikku Huopalahden ala-aste" },
        "03674" => { name: "Nordsjö lågstadieskola" },
        "03705" => { name: "Torpparinmäen peruskoulu" },
        "03716" => { name: "Strömbergin ala-asteen koulu" },
        "03723" => { name: "Poikkilaakson ala-asteen koulu" },
        "03724" => { name: "Aurinkolahden peruskoulu" },
        "03743" => { name: "Arabian peruskoulu" },
        "03763" => { name: "Sakarinmäen peruskoulu" },
        "03769" => { name: "Latokartanon peruskoulu" },
        "03782" => { name: "Helsingin eurooppalainen koulu" },
        "03845" => { name: "Kalasataman peruskolu" },
        "03852" => { name: "Jätkäsaaren peruskoulu" },
        "03880" => { name: "Vattuniemen ala-aste" },
        "03886" => { name: "Kruunuvuorenrannan peruskoulu" },
        "03861" => { name: "Helsingin Montessorikoulu" },
        "05676" => { name: "Östersundom skola" },
        "10016" => { name: "Yrkesinstitutet Prakticum" },
        "10079" => { name: "Keskuspuiston ammattiopisto" },
        "10086" => { name: "Business College Helsinki" },
        "10105" => { name: "Stadin ammattiopisto" },
        "10120" => { name: "Perho Liiketalousopisto" },
        "00000" => { name: "Other" }
      }.freeze

      def self.exists?(school)
        metadata_for_school(school).present?
      end

      def self.metadata_for_school(school)
        MAPPING[school]
      end

      def self.school_name(school)
        data = metadata_for_school(school)
        return nil unless data

        data[:name]
      end

      def self.school_options
        options = [].tap do |array|
          MAPPING.map do |key, value|
            next if key == "00000"

            array << [value[:name], key]
          end
        end
        result = options.sort_by { |item| item[0] }
        result << %w(Other 00000)
      end
    end
  end
end
