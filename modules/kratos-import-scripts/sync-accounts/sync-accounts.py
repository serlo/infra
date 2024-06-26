import os
import psycopg2
import psycopg2.extras
import ory_client
from ory_client.api import identity_api
import requests

postgres_connection = None

kratos_config = ory_client.Configuration(host="kratos-admin")
kratos_client = ory_client.ApiClient(kratos_config)


def main():
    try:
        postgres_connection = psycopg2.connect(
            database="kratos",
            host=os.getenv("POSTGRES_HOST"),
            user="serlo_readonly",
            password=os.getenv("POSTGRES_PASSWORD"),
        )
        postgres_cursor = postgres_connection.cursor(
            cursor_factory=psycopg2.extras.RealDictCursor
        )
        postgres_cursor.execute(
            "SELECT * FROM identities WHERE (metadata_public->'legacy_id') is null"
        )
        unsynced_accounts = postgres_cursor.fetchall()

        print(f"{len(unsynced_accounts)} accounts to be synchronized")

        kratos_admin = identity_api.IdentityApi(kratos_client)

        for account in unsynced_accounts:
            response = requests.post(
                "http://serlo-org-database-layer.api:8080",
                json={
                    "type": "UserCreateMutation",
                    "payload": {
                        "username": account["traits"]["username"],
                        "email": account["traits"]["email"],
                        "password": account["id"],
                    },
                },
            )
            kratos_response = None
            if response.status_code == 200:
                legacy_id = {"legacy_id": response.json()["userId"]}
                kratos_response = kratos_admin.update_identity(
                    account["id"],
                    update_identity_body={
                        **account,
                        "metadata_public": dict(legacy_id, **account["metadata_public"])
                        if isinstance(account["metadata_public"], dict)
                        else legacy_id,
                    },
                )
            # It handle cases in which the user exists in legacy db
            # but kratos was not updated with legacy_id
            else:
                response = requests.post(
                    "http://serlo-org-database-layer.api:8080",
                    json={
                        "type": "AliasQuery",
                        "payload": {
                            "instance": "de",
                            "path": f"/user/profile/{account['traits']['username']}",
                        },
                    },
                )
                legacy_id = {"legacy_id": response.json()["id"]}
                kratos_response = kratos_admin.update_identity(
                    account["id"],
                    update_identity_body={
                        **account,
                        "metadata_public": dict(legacy_id, **account["metadata_public"])
                        if isinstance(account["metadata_public"], dict)
                        else legacy_id,
                    },
                )

            print(
                f"{kratos_response['traits']['username']} with legacy_id {kratos_response['metadata_public']['legacy_id']} was updated"
            )
        print("Success")
    except Exception as exception:
        raise exception
    finally:
        if postgres_connection is not None:
            postgres_connection.close()


if __name__ == "__main__":
    main()
