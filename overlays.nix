{ 
    additions = final: prev:
    {
        ci-lib = 
        {
            pushContainerToRegistry = { streamLayeredImage, imageUrlWithTag, registryUser, registryPassword }:
            final.writeShellApplication
            {
                name          = "pushToRegistry.sh";
                runtimeInputs = with final; [ gzip skopeo bash ];
                text          = 
                ''
                     ${streamLayeredImage} | gzip --fast | \
                        skopeo copy docker-archive:/dev/stdin docker://${imageUrlWithTag} \
                        --dest-creds ${registryUser}:${registryPassword} --insecure-policy
                '';
            };

            createMultiArchManifest = { imageUrlWithoutTag, tag, registryUser, registryPassword }: 
            final.writeShellApplication
            {
                name          = "createMultiArchManifest.sh";
                runtimeInputs = with final; [ manifest-tool ];
                text          = 
                ''
                    manifest-tool --username ${registryUser} --password ${registryPassword} push from-args \
                        --platforms linux/amd64,linux/arm64 \
                        --template ${imageUrlWithoutTag}-ARCH:${tag} \
                        --target ${imageUrlWithoutTag}:${tag}
                '';
            };
            
            retagImage = { registryBaseUrl, imageUrlWithTag, newTag, registryUser, registryPassword }: 
            final.writeShellApplication
            {
                name          = "retagImage.sh";
                runtimeInputs = with final; [ crane ];
                text          = 
                ''
                    crane auth login -u ${registryUser} -p ${registryPassword} ${registryBaseUrl}
                    crane tag ${imageUrlWithTag} ${newTag}
                '';
            };
        };
    };
}