using UnityEngine;

namespace StarrySky
{
	public class StarryObject : MonoBehaviour
	{
		public Material m_Mat;
		public GameObject[] m_StarryObjs;
		[Range(0.1f, 0.5f)] public float m_DistFading = 0.2f;
		[Range(0.001f, 0.008f)] public float m_Brightness = 0.0035f;
		RenderTexture m_RTStarry;

		void Start()
		{
			m_RTStarry = new RenderTexture(512, 512, 0);
			m_RTStarry.wrapMode = TextureWrapMode.Repeat;
		}
		void Update()
		{
			m_Mat.SetFloat("_DistFading", m_DistFading);
			m_Mat.SetFloat("_Brightness", m_Brightness);
			Graphics.Blit(null, m_RTStarry, m_Mat);

			for (int i = 0; i < m_StarryObjs.Length; i++)
			{
				GameObject obj = m_StarryObjs[i];
				Renderer rd = obj.GetComponent<Renderer>();
				Material[] mats = rd.materials;
				Material theMat = null;

				if (mats.Length == 1)
					theMat = mats[0];
				else if (mats.Length == 2)
					theMat = mats[1];  // the eye material of zombunny
				theMat.mainTexture = m_RTStarry;
			}
		}
	}
}
