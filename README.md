# ANY — Anything, Anywhere, Anytime

## Concept
Carte communautaire interactive des services en libre-service 24h/24.
Trouvez un lieu utile autour de vous, peu importe où vous êtes et quand — vanlifer, vacancier, citadin ou nomade.

## Stack technique
- **Frontend** : HTML/CSS/JS vanilla (fichier unique index.html)
- **Carte** : Leaflet.js + Leaflet.MarkerCluster + OpenStreetMap + Esri satellite
- **Base de données** : Supabase (PostgreSQL)
- **Auth** : Supabase Auth
- **Hébergement** : GitHub Pages

## Credentials Supabase
- URL : https://xssfehwbmvrxtxmocowc.supabase.co
- Clé publique : sb_publishable_lB89hOOAXUCIheGRbS2wEQ_L7uVajNV
- Projet ID : xssfehwbmvrxtxmocowc

## URL
- App : https://my-projet-app.github.io/ANY/
- Import : https://my-projet-app.github.io/ANY/import.html
- Admin : https://my-projet-app.github.io/ANY/admin.html

## Structure base de données

### Tables
- main_categories : grandes catégories (sort_order, name, icon, color)
- categories : sous-catégories (main_category_id, name, icon, color, min_role, allow_photos)
- places : lieux (name, description, latitude, longitude, category_id, user_id, validation_weight, status)
- place_validations : (place_id, user_id, weight) — validation communautaire
- votes : (place_id, user_id, vote boolean)
- comments : (place_id, user_id, user_name, content)
- profiles : (user_id UNIQUE, username, avatar_url, registered_at)
- trusted_users : (user_id, role) — admin / moderator / trusted
- favorites : favoris des utilisateurs
- reports / report_history : signalements et historique modération
- place_photos : photos des lieux
- notifications : notifications in-app
- comment_reports : signalements de commentaires
- ratings : notes des lieux

### Index de performance
- places_cat_status_latlon_idx : (category_id, status, latitude, longitude)
- places_user_id_idx : (user_id) sur places
- pv_user_id_idx : (user_id) sur place_validations
- fav_user_id_idx : (user_id) sur favorites

### Fonctions RPC
- load_places_near : chargement POIs par bbox optimisé
- get_registered_users_count / get_new_users_count : stats membres
- admin_delete_places_batch(cat_id, batch_size) : suppression POIs par lots
- admin_delete_category(cat_id) : suppression catégorie (SECURITY DEFINER)

### Politiques RLS notables
- categories DELETE : réservé aux admins (trusted_users.role = 'admin')

## Système de validation des POI
- Seuil : validation_weight >= 3 = POI validé (icône en couleur)
- User normal +1 / Trusted +2 / Admin-Mod valide instantanément
- Badges : 0 vote = à valider | 1-2 votes = X/3 | validé = icône couleur

## Système XP
- Lieu ajouté +10 / Confirmation +3 / Commentaire +2 / Vote +1 / Merci reçu +5
- Niveaux : Curieux > Explorateur > Contributeur > Guide > Ambassadeur

## Fonctionnalités
- Carte interactive avec clusters adaptatifs (rayon selon zoom)
- Vue satellite hybride (membres connectés)
- Filtres par catégorie + recherche textuelle + périmètre
- Ajout de lieux avec photo obligatoire
- Votes, commentaires, favoris, validation communautaire
- Profil utilisateur avec progression XP
- Dashboard Mon espace : lieux, validations, favoris, stats globales
- Modération avancée (dashboard mods/admins)
- Notifications push (Web Push API)
- PWA installable iOS + Android
- Interface responsive : nav bas en portrait, nav gauche en paysage (Dynamic Island géré)
- 7 langues (fr, en, es, de, it, pt, nl)

## Performance
- Chargement carte : RPC load_places_near avec index composite
- Dashboard : cache localStorage Phase 1 (60s) + Phase 2 (5 min)
- Suppression catégorie : RPC batch pour éviter timeouts API (300k+ POIs)
- Filtre par défaut : seulement Libre service 24/7 au démarrage

## Fichiers
- index.html : application principale (~8370 lignes)
- sw.js : service worker (cache CDN + notifications push)
- manifest.json : PWA manifest
- import.html : outil import OpenStreetMap (Overpass API, 5 miroirs)
- import-pizza.html : outil géocodage adresses manuelles
