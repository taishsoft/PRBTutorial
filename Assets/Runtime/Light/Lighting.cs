using Unity.Collections;
using UnityEngine;
using UnityEngine.Rendering;

public class Lighting
{
    const string bufferName = "Lighting";

    CommandBuffer buffer = new CommandBuffer
    {
        name = bufferName
    };

    static int
        dirLightColorId = Shader.PropertyToID("_DirectionalLightColor"),
        dirLightDirectionId = Shader.PropertyToID("_DirectionalLightDirection");

    CullingResults cullingResults;

    public void Setup(ScriptableRenderContext context, CullingResults cullingResults)
    {
        this.cullingResults = cullingResults;
        buffer.BeginSample(bufferName);
        SetupLights();
        buffer.EndSample(bufferName);
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }

    //设置灯光，支持多盏平行光，目前只取一盏
    void SetupLights()
    {
        NativeArray<VisibleLight> visibleLights = cullingResults.visibleLights;
        if (visibleLights.Length == 0)
        {
            buffer.SetGlobalColor(dirLightColorId, new Color(0, 0, 0, 0));
        }
        else
        {
            for (int i = 0; i < visibleLights.Length; i++)
            {
                VisibleLight light = visibleLights[i];
                if (light.lightType == LightType.Directional)
                {
                    SetupDirectionalLight(ref light);
                    break;
                }
            }
        }        
    }

    void SetupDirectionalLight(ref VisibleLight visibleLight)
    {
        buffer.SetGlobalVector(dirLightColorId, visibleLight.finalColor);
        //以下两种写法都可以获取到平行光的方向
        //buffer.SetGlobalVector(dirLightDirectionId, -visibleLight.localToWorldMatrix.GetColumn(2));
        buffer.SetGlobalVector(dirLightDirectionId, -visibleLight.light.transform.forward);
    }
}